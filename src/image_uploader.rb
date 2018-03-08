def image_upload(img, id)
  logger.info "upload now"
  tempfile = img[:tempfile]
  
  upload = Cloudinary::Uploader.upload(tempfile.path)

  contents = Event.find(id)
  puts upload
  contents.update_attribute(:image_url, upload['url'])
end
