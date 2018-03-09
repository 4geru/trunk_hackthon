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
    n1.pushButton('新しく登録するで', {"message": "data1", "data": "nil"})#[TODO] 自分の登録している一覧へ
    n1.pushUri('登録したやつ全部見よか', {"uri": "https://trunk-hackers-a4geru.c9users.io/user/#{user.id}"})
    client.reply_message(event['replyToken'], [
      sadSticky,
      n.reply([n1.getButtons('検索結果やで', "まだイベント登録がされてへんで。はよしよーや。")])
    ])
  elsif events.length < 5
    # そのまま表示
    # 端っこを切る
    cnt = 0
    list = []  
    m = MessageCarousel.new('イベント選択してるで')
    
    for e in events
      m1 = MessageButton.new('hoge', e.image_url)
      title = e.event_name
      text = e.detail
      m1.pushUri("詳細見てみよか\u{1F50E}", {"uri": "https://trunk-hackers-a4geru.c9users.io/event/#{e.id}?openExternalBrowser=1"})
      if Participant.where({user_id: user.id, event_id: e.id }).empty?
        m1.pushButton("参加するで\u{1F44D}", {"data": "type=join&event_id=#{e.id}"}) 
      else
        m1.pushButton("ごめんやけどキャンセルで\u{1F44E}", {"data": "type=leave&event_id=#{e.id}"})     
      end 

      list << m1.getButtons(title, text)
    end
    n = MessageCarousel.new('webへのリンク')
    n1 = MessageButton.new('hoge')
    n1.pushUri('登録したやつ全部見よか', {"uri": "https://trunk-hackers-a4geru.c9users.io/user/#{user.id}"})#[TODO] 自分の登録している一覧へ
    client.reply_message(event['replyToken'], [
        m.reply(list), # 結果リスト
        n.reply([n1.getButtons('検索結果', "#{participants.length}件のデータが登録されてるで。\n詳しいのんはwebでみれるで。")])
      ])
  else
    p "hogehoge >> #{participants.length}"
    events = events[0...events.length-(events.length % 5)]
    cnt = 0
    list = []
    m = MessageCarousel.new('イベント選択してるで')
    
    for i in 0...5
      m1 = MessageButton.new('hoge', events[cnt].image_url)
      title = events[cnt].event_name
      text = events[cnt].detail
      m1.pushUri("詳細を見る\u{1F50E}", {"uri": "https://trunk-hackers-a4geru.c9users.io/event/#{events[cnt].id}?openExternalBrowser=1"})
      if Participant.where({user_id: user.id, event_id: events[cnt].id }).empty?
        m1.pushButton("参加するで\u{1F44D}", {"data": "type=join&event_id=#{events[cnt].id}"}) 
      else
        m1.pushButton("ごめんやけどキャンセルで\u{1F44E}", {"data": "type=leave&event_id=#{events[cnt].id}"})     
      end
      cnt += 1
      list << m1.getButtons(title, text)
    end
    p user
    n = MessageCarousel.new('webページへ')
    n1 = MessageButton.new('hoge')
    n1.pushUri("\u{1F4D5} 登録したやつ全部見よか", {"uri": "https://trunk-hackers-a4geru.c9users.io/user/#{user.id}"})#[TODO] 自分の登録している一覧へ
    client.reply_message(event['replyToken'], [
        m.reply(list), # 結果リスト
        n.reply([n1.getButtons('検索結果', "新しいのん5件表示されてるで。\n#{participants.length}件のデータが登録されてるで。\n詳しいのんはwebでみれるで。")])
      ])
  end
end