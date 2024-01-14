source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.4", ">= 7.0.4.1"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"
# gem "tzinfo-data"
gem 'rack-cors'
# Use mysql as the database for Active Record
# gem "mysql2", "~> 0.5.4"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use PG's postgis extension
gem 'rgeo'
gem 'activerecord-postgis-adapter'

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.4.2"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Enable .env file
gem 'dotenv-rails'

# Use Sass to process CSS
# gem "sassc-rails"
# gem 'faker', :git => 'https://github.com/faker-ruby/faker.git', :branch => 'main'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'rspec-rails', '~> 6.0.0'
  gem 'httparty'
  gem 'faker'
  gem 'database_cleaner'
  gem 'rubocop', require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem 'simplecov', require: false
end

# O-Auth
gem "omniauth-twitter", "~> 1.4"
gem "omniauth-github", "~> 2.0"
gem "omniauth-google-oauth2", "~> 1.1"
gem "omniauth-rails_csrf_protection", "~> 1.0"

# Notifications
gem "noticed", "~> 1.6"

# DB Performance 
gem "bullet", "~> 7.0"
gem "benchmark", "~> 0.2.1"

gem "activerecord-import", "~> 1.4"

# Pagination & Querying
gem "pg_search"
gem 'kaminari'
gem 'geocoder'
gem 'actiontext'
gem 'trix'
gem 'dalli'
gem 'activestorage-backblaze'
gem 'iso_country_codes'
gem 'composite_primary_keys'

# Rich-Text Support
gem 'actionpack', '>= 7.0.5.1'
gem 'activesupport', '>= 7.0.7.1'
gem 'nokogiri', '>= 1.14.3'

# Payments and Subscriptions
gem "stripe", "~> 10.4"
gem "pay", "~> 7.1"

# Enable Soft Delete
gem "paranoia", "~> 2.6"
