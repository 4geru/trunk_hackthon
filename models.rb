ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")
class User < ActiveRecord::Base
  validates :channel_id, uniqueness: true
  has_many :participants
end

class Event < ActiveRecord::Base
  has_many :participants
end

class Participant < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
end