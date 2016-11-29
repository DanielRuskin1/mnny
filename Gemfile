ruby "2.2.2"

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# OAuth authentication
gem 'omniauth', '~> 1.3.1'
gem 'omniauth-google-oauth2', '~> 0.3.1'

# Pagination
gem 'will_paginate', '~> 3.1.0'

# Email validation
gem 'validates_email_format_of', '~> 1.6.3'

# Styling
gem 'bootstrap', '~> 4.0.0.alpha5'

# Exception handling
gem 'oj', '~> 2.12.14'
gem 'rollbar', '~> 2.13.2'

# Money
gem 'money-rails', '~> 1.7.0'

# Graphing
gem "d3-rails", "~> 4.1.0"

# Locking
gem "with_advisory_lock", "~> 3.0.0"

# Outgoing emails
gem "postmark-rails", "~> 0.14.0"

# File uploads
gem "carrierwave", "~> 1.0.0.rc"
gem "fog", "~> 1.38.0"
gem 'carrierwave_direct', "~> 0.0.15"

# Env
gem "dotenv-rails", "~> 2.1.1", groups: [:development, :test]

# Fonts
gem "font-awesome-rails", "~> 4.7.0.0"

# Web requests
gem "faraday", "~> 0.9.2"
gem "faraday_middleware", "~> 0.10.0"

# Memcache
gem 'dalli', "~> 2.7.6"

# User tracking
gem "em-http-request", "~> 1.0"
gem 'keen', '~> 0.9.6'

# App tracking
gem 'newrelic_rpm', "~> 3.17.1.326"

# Stock prices
gem "stock_quote", "~> 1.2.3"

source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.1.0'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :test do
  gem 'rspec-rails', '~> 3.5.2'
  gem 'capybara', '~> 2.10.1'
  gem "factory_girl_rails", "~> 4.7.0"
  gem 'poltergeist', "~> 1.11.0"
  gem 'phantomjs', require: 'phantomjs/poltergeist'
  gem 'database_cleaner', "~> 1.5.3"
  gem "timecop", "~> 0.8.0"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
