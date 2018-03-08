require './src/class/messagebutton'
require './src/class/messagecarousel'
require './src/class/messageconfirm'
require './src/event/postback'
require './src/line/search'
require './src/line/register'
require './src/lib/stamps'

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
        if event.message['text'] =~ /探す/ or event.message['text'] == 'イベントを探す'
          searchAction(event)
        elsif event.message['text'] == '登録一覧へ'
          registerAction(event)
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
    when Line::Bot::Event::Follow
      client.reply_message(event['replyToken'], { type: 'text', text: "友達追加ありがとうございます！こちらのアカウントでは関西で開催されるギークなイベントをご紹介しております。プログラミングに少し興味を持ち始めた方や，これから始めようと思っている方にぜひ参加していただきたいイベントをご紹介するので，ご期待ください。" }) # TODO書く
    when Line::Bot::Event::Postback
      eventPostBack(event)
    end
  }

  "OK"
end