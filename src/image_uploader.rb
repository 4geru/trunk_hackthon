def image_upload(img)
  logger.info "upload now"
  tempfile = img[:tempfile]
  
  upload = Cloudinary::Uploader.upload(tempfile.path)

  contents = Event.last

  contents.update_attribute(:image_url, upload['url'])
end
