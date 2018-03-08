def searchAction(event)
  len = [(Event.all.length / 3).to_i, 5].min
  events = Event.all.shuffle.take(len * 3)
  list = []
  m  = MessageCarousel.new('イベント選択中')
  
  cnt = 0
  for i in 0...len
    m1 = MessageButton.new('hoge', events[cnt].image_url)
    title = events[cnt].event_name
    text = events[cnt].detail
    m1.pushButton(events[cnt].event_name, {"data": "type=allEvent&event_id=#{events[cnt].id}"}) 
    cnt += 1
    m1.pushButton(events[cnt].event_name, {"data": "type=allEvent&event_id=#{events[cnt].id}"}) 
    cnt += 1
    m1.pushButton(events[cnt].event_name, {"data": "type=allEvent&event_id=#{events[cnt].id}"}) 
    cnt += 1
    list << m1.getButtons(title, text)
  end
  client.reply_message(event['replyToken'], m.reply(list))
end