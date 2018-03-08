def registerAction(event)
  user = User.where({user_id: event["source"]["userId"]}).first
  # 15件までを表示
  participants = Participant.where({user_id: user.id }).shuffle[0...15]
  events = participants.map{|part| part.event }
  all = participants.length
  p events.length
  if events.length == 0
    p 'get'
    n = MessageCarousel.new('webへのリンク')
    n1 = MessageButton.new('hoge')
    n1.pushButton('新たに登録する', {"message": "data1", "data": "nil"})#[TODO] 自分の登録している一覧へ
    n1.pushUri('登録一覧ページへ', {"uri": "https://trunk-hackers-a4geru.c9users.io/user/#{user.id}"})#[TODO] 自分の登録している一覧へ
    client.reply_message(event['replyToken'], [
        n.reply([n1.getButtons('検索結果', "まだイベントの登録がされていません、登録しましょう！")])
      ])
  elsif events.length < 5
    # そのまま表示
    # 端っこを切る
    cnt = 0
    list = []  
    m = MessageCarousel.new('イベント選択中')
    
    for e in events
      m1 = MessageButton.new('hoge', e.image_url)
      title = e.event_name
      text = e.detail
      m1.pushButton(e.event_name, {"data": "type=allEvent&event_id=#{e.id}"}) 
      list << m1.getButtons(title, text)
    end
    n = MessageCarousel.new('webへのリンク')
    n1 = MessageButton.new('hoge')
    n1.pushUri('登録一覧ページへ', {"uri": "https://trunk-hackers-a4geru.c9users.io/user/#{user.id}"})#[TODO] 自分の登録している一覧へ
    client.reply_message(event['replyToken'], [
        m.reply(list), # 結果リスト
        n.reply([n1.getButtons('検索結果', "#{all}件のデータが登録されています。\n詳しくはwebでの閲覧が可能です。")])
      ])
  else
    # p events
    events = events[0...events.length-(events.length % 5)]
    cnt = 0
    list = []
    m = MessageCarousel.new('イベント選択中')
    
    for i in 0...5
      m1 = MessageButton.new('hoge', events[cnt].image_url)
      title = events[cnt].event_name
      text = events[cnt].detail
      for j in 0...events.length/5
        m1.pushButton(events[cnt].event_name, {"data": "type=allEvent&event_id=#{events[cnt].id}"}) 
        cnt += 1
      end
      list << m1.getButtons(title, text)
    end
    n = MessageCarousel.new('webへのリンク')
    n1 = MessageButton.new('hoge')
    n1.pushUri('登録一覧ページへ', {"uri": "https://trunk-hackers-a4geru.c9users.io/user/#{user.id}"})#[TODO] 自分の登録している一覧へ
    client.reply_message(event['replyToken'], [
        m.reply(list), # 結果リスト
        n.reply([n1.getButtons('検索結果', "#{all}件のデータが登録されています。\n詳しくはwebでの閲覧が可能です。")])
      ])
  end
end