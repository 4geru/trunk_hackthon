class MessageButton
  def initialize(altText = nil, image = nil)
    @buttons = []
    @altText = altText
    @image = image
  end

  def reply(title = nil, text = nil)
  return nil if @buttons.length == 0
  return nil if title.nil?
  return nil if text.nil?
  {
    "type": "template",
    "altText": @altText || "this is a buttons template",
    "template": {
        "type": "buttons",
        "title": title,
        "text": text,
        "actions": @buttons
    }
  }
  end

  def getButtons(title = nil, text = nil)
    return nil if @buttons.length == 0
    return nil if title.nil?
    return nil if text.nil?
    {
      "title": title,
      "thumbnailImageUrl": @image,
      "text": text,
      "actions": @buttons
    }
  end
  # option : {data=nil, url=nil}
  def pushButton(label='', option)
    @buttons.push(option.merge({"type": "postback", "label": label[0..10]}))
  end

  # option : {data=nil, url=nil}
  def pushUri(label='', option)
    @buttons.push(option.merge({"type": "uri", "label": label[0..10]}))
  end
end