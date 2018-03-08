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
    m1.pushUri('詳細を見る', {"uri": "https://trunk-hackers-a4geru.c9users.io/event/#{events.id}"})
    if Participant.where({user_id: user.id, event_id: events.id }).empty?
      m1.pushButton('参加する', {"data": "type=join&event_id=#{events.id}"}) 
    else
      m1.pushButton('キャンセルする', {"data": "type=leave&event_id=#{events.id}"})     
    end 
    client.reply_message(event['replyToken'], m.reply([ m1.getButtons(title, text)]))
  when "join"
    events = Event.find(data["event_id"])
    m = MessageConfirm.new('確定確認中')
    m.pushButton('はい',   {"data": "type=confirm&event_id=#{events.id}&status=true"})
    m.pushButton('いいえ', {"data": "type=confirm&event_id=#{events.id}&status=false"})
    client.reply_message(event['replyToken'], m.reply("「#{events.event_name}」を確定しますか？"))
  when "leave"
    events = Event.find(data["event_id"])
    Participant.where({user_id: user.id, event_id: events.id }).first.destroy
    client.reply_message(event['replyToken'], { type: 'text', text: "「#{events.event_name}」をキャンセルしました。" })
  when "confirm"
    events = Event.find(data["event_id"])
    if data["status"] == 'true'
      m = MessageConfirm.new('確定確認中')
      m.pushButton('はい',   {"data": "type=check&status=true&event_id=#{events.id}"})
      m.pushButton('いいえ', {"data": "type=check&status=false&event_id=#{events.id}"})
      client.reply_message(event['replyToken'], m.reply("本当に「#{events.event_name}」を確定しますか？"))
    else
      client.reply_message(event['replyToken'], { type: 'text', text: "「#{event.event_name}」をキャンセルしました。" })
    end
  when "check"    
    events = Event.find(data["event_id"])
    user = User.where({user_id: event["source"]["userId"]}).first
    if data["status"] == 'true'
      Participant.find_or_create_by({user_id: user.id, event_id: events.id })
      client.reply_message(event['replyToken'], { type: 'text', text: "「#{events.event_name}」を確定しました。" })
    else
      client.reply_message(event['replyToken'], { type: 'text', text: "「#{events.event_name}」をキャンセルしました。" })
    end
  end
end