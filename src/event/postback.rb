def eventPostBack(event)
  user = User.where({user_id: event["source"]["userId"]}).first
  data = Hash[URI::decode_www_form(event["postback"]["data"])]
  p data
  case data["type"]
  when "allEvent"
    events = Event.find(data["event_id"])
    m  = MessageCarousel.new('イベント選択中')
    
    m1 = MessageButton.new('hoge', events.image_url)
    title = events.event_name
    text = events.detail
    m1.pushUri("詳細を見る\u{1F50E}", {"uri": "#{ENV["BASE_URL"]}/event/#{events.id}?openExternalBrowser=1"})
    if Participant.where({user_id: user.id, event_id: events.id }).empty?
      m1.pushButton("参加すんの\u{1F44D}", {"data": "type=join&event_id=#{events.id}"}) 
    else
      m1.pushButton("キャンセルすんの\u{1F44E}", {"data": "type=leave&event_id=#{events.id}"})     
    end 
    client.reply_message(event['replyToken'], m.reply([ m1.getButtons(title, text)]))
  when "join"
    events = Event.find(data["event_id"])
    m = MessageConfirm.new('確定確認中')
    m.pushButton("\u{2B55} はい",   {"data": "type=confirm&event_id=#{events.id}&status=true"})
    m.pushButton("\u{274C} いいえ", {"data": "type=confirm&event_id=#{events.id}&status=false"})
    client.reply_message(event['replyToken'], m.reply("「#{events.event_name}」を確定していいか？"))
  when "leave"
    events = Event.find(data["event_id"])
    Participant.where({user_id: user.id, event_id: events.id }).first.destroy
    client.reply_message(event['replyToken'], { type: 'text', text: "「#{events.event_name}」をキャンセルしたで" })
  when "confirm"
    events = Event.find(data["event_id"])
    if data["status"] == 'true'
      m = MessageConfirm.new('再確定確認中')
      m.pushButton("\u{2B55} はい",   {"data": "type=check&status=true&event_id=#{events.id}"})
      m.pushButton("\u{274C} いいえ", {"data": "type=check&status=false&event_id=#{events.id}"})
      client.reply_message(event['replyToken'], [confirmSticky, m.reply("ほんまに「#{events.event_name}」を確定していいか？")])
    else
      client.reply_message(event['replyToken'], [sadSticky, { type: 'text', text: "「#{events.event_name}」をキャンセルしたで" }])
    end
  when "check"    
    events = Event.find(data["event_id"])
    user = User.where({user_id: event["source"]["userId"]}).first
    if data["status"] == 'true'
      Participant.find_or_create_by({user_id: user.id, event_id: events.id })
      client.reply_message(event['replyToken'], [happySticky, { type: 'text', text: "「#{events.event_name}」を確定したで" }])
    else
      client.reply_message(event['replyToken'], [sadSticky, { type: 'text', text: "「#{events.event_name}」をキャンセルしたで" }])
    end
  end
end