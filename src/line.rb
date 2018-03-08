require './src/class/messagebutton'
require './src/class/messagecarousel'
require './src/class/messageconfirm'
require './src/event/postback'
def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    user = nil
    if User.where({user_id: event["source"]["userId"]}).first
      user = User.find_or_create_by({user_id: event["source"]["userId"]})
    else
      user = User.find_or_create_by({user_id: event["source"]["userId"], status:'first'})
    end

    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        if event.message['text'] =~ /探す/
          
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
        else
          message = {
            type: 'text',
            text: event.message['text']
          }
          client.reply_message(event['replyToken'], message)
        end
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
        
      end
    when Line::Bot::Event::Postback
      eventPostBack(event)
    end
  }

  "OK"
end