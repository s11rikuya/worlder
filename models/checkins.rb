# require 'sqlite3'
require 'sinatra/activerecord'

ActiveRecord::Base.configurations = YAML.load_file('db/myapp.yml')
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || :development)

class Checkin < ActiveRecord::Base
end
