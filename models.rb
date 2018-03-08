ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")
class User < ActiveRecord::Base
  validates :user_id, uniqueness: true
  has_many :participants
  has_many :events
end

class Event < ActiveRecord::Base
  has_many :participants
  belongs_to :user
  def photo
    if self.image_url =~ /cloudinary/
      self.image_url.split('/').map{|i| i =~ /upload/ ? "upload/w_600" : i}.join('/')
    else
      self.image_url
    end
  end
end

class Participant < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
end
