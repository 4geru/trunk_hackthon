def image_upload(img = nil, id = nil)
  puts "log img >> #{img},id >>  #{id}"
  logger.info "upload now"
  tempfile = img[:tempfile]
  
  upload = Cloudinary::Uploader.upload(tempfile.path)

  contents = Event.find(id)
  contents.update_attribute(:image_url, upload['url'])
end
