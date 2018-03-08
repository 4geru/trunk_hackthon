ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")
class User < ActiveRecord::Base
  validates :channel_id, uniqueness: true
end

class Event < ActiveRecord::Base

end
