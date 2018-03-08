def eventPostBack(event)
  data = Hash[URI::decode_www_form(event["postback"]["data"])]
  case data["type"]
  when "allEvent"
    events = Event.find(data["event_id"])
    p events
    m  = MessageCarousel.new('イベント選択中')
    
    m1 = MessageButton.new('hoge', events.image_url)
    title = events.event_name
    text = events.detail
    m1.pushButton('詳細を見る', {"data": "type=watch&event_id=#{events.id}"})# URIに書き換える
    m1.pushButton('参加する', {"data": "type=join&event_id=#{events.id}"}) 
    client.reply_message(event['replyToken'], m.reply([ m1.getButtons(title, text)]))
  end
  p data
end