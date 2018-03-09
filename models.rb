ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")
class User < ActiveRecord::Base
  validates :user_id, uniqueness: true
  has_many :participants
  has_many :events
end

class Event < ActiveRecord::Base
  has_many :participants
  belongs_to :user
  validates :event_name, presence: true
  validates :start_time, presence: true
  validates :detail, presence: true
  validates :end_time, presence: true
  validates :user_id, presence: true
  
  def photo
    if self.image_url =~ /cloudinary/
      self.image_url.split('/').map{|i| i =~ /upload/ ? "upload/w_600" : i}.join('/')
    else
      self.image_url
    end
  end
  
  def join(user_id)
    return false if self.participants.empty?
    self.participants.any?{|p| p.user_id.to_i == user_id}
  end
end

class Participant < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
end
