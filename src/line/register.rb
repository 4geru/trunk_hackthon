def registerAction(event)
  user = User.where({user_id: event["source"]["userId"]}).first
  # 15件までを表示
  participants = Participant.where({user_id: user.id })
  p participants
  events = participants.map{|part| part.event }.reverse[0...5]
  all = participants.length
  if events.length == 0
    n = MessageCarousel.new('webへのリンク')
    n1 = MessageButton.new('hoge')
    n1.pushButton('新たに登録する', {"message": "data1", "data": "nil"})#[TODO] 自分の登録している一覧へ
    n1.pushUri('登録一覧ページへ', {"uri": "https://trunk-hackers-a4geru.c9users.io/user/#{user.id}"})
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
      m1.pushUri('詳細を見る', {"uri": "https://trunk-hackers-a4geru.c9users.io/event/#{e.id}?openExternalBrowser=1"})
      m1.pushButton(e.event_name, {"data": "type=allEvent&event_id=#{e.id}"}) 
      if Participant.where({user_id: user.id, event_id: e.id }).empty?
        m1.pushButton('参加する', {"data": "type=join&event_id=#{e.id}"}) 
      else
        m1.pushButton('キャンセルする', {"data": "type=leave&event_id=#{e.id}"}) 
      end 
      list << m1.getButtons(title, text)
    end
    n = MessageCarousel.new('webへのリンク')
    n1 = MessageButton.new('hoge')
    n1.pushUri('登録一覧ページへ', {"uri": "https://trunk-hackers-a4geru.c9users.io/user/#{user.id}"})#[TODO] 自分の登録している一覧へ
    client.reply_message(event['replyToken'], [
        m.reply(list), # 結果リスト
        n.reply([n1.getButtons('検索結果', "#{participants.length}件のデータが登録されています。\n詳しくはwebでの閲覧が可能です。")])
      ])
  else
    p "hogehoge >> #{participants.length}"
    events = events[0...events.length-(events.length % 5)]
    cnt = 0
    list = []
    m = MessageCarousel.new('イベント選択中')
    
    for i in 0...5
      m1 = MessageButton.new('hoge', events[cnt].image_url)
      title = events[cnt].event_name
      text = events[cnt].detail
      m1.pushUri('詳細を見る', {"uri": "https://trunk-hackers-a4geru.c9users.io/event/#{events[cnt].id}"})
      if Participant.where({user_id: user.id, event_id: events[cnt].id }).empty?
        m1.pushButton('参加する', {"data": "type=join&event_id=#{events[cnt].id}"}) 
      else
        m1.pushButton('キャンセルする', {"data": "type=leave&event_id=#{events[cnt].id}"}) 
      end 
      cnt += 1
      list << m1.getButtons(title, text)
    end
    p user
    n = MessageCarousel.new('webへのリンク')
    n1 = MessageButton.new('hoge')
    n1.pushUri('登録一覧ページへ', {"uri": "https://trunk-hackers-a4geru.c9users.io/user/#{user.id}"})#[TODO] 自分の登録している一覧へ
    client.reply_message(event['replyToken'], [
        m.reply(list), # 結果リスト
        n.reply([n1.getButtons('検索結果', "最新5件が表示されています。\n#{participants.length}件のデータが登録されています。\n詳しくはwebでの閲覧が可能です。")])
      ])
  end
end