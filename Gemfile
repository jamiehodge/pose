source :rubygems

gem 'sinatra'
gem 'rack-parser'
gem 'yajl-ruby', require: 'yajl'

gem 'sequel'
gem 'sqlite3'

# gem 'stalker'

group :development do
  gem 'guard', github: 'guard', branch: 'listen'
  gem 'listen'
  
  gem 'guard-minitest'
end

group :test do
  gem 'rack-test', github: 'brynary/rack-test'
  gem 'fabrication'
end