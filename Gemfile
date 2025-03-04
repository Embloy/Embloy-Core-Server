source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'
gem 'mawsitsit', '~> 0.1.18'
# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.4', '>= 7.0.4.1'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'
# gem "tzinfo-data"
gem 'rack-cors', '~> 2.0', '>= 2.0.2'
# Use mysql as the database for Active Record
# gem "mysql2", "~> 0.5.4"

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use PG's postgis extension
gem 'activerecord-postgis-adapter'
gem 'rgeo'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6.4.2'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Enable .env file
gem 'dotenv-rails'

# Use Sass to process CSS
gem 'sassc-rails'
# gem 'faker', :git => 'https://github.com/faker-ruby/faker.git', :branch => 'main'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem 'image_processing', '~> 1.2'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'database_cleaner'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'faker'
  gem 'httparty'
  gem 'panolint', require: false
  gem 'rspec-rails', '~> 6.0.0'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails_config', require: false
  gem 'rubocop-rake', require: false
end

group :development do
  gem 'activestorage-backblaze'
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'overcommit', '~> 0.63.0'
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :production do
  gem 'aws-sdk-s3', '~> 1.159'
  gem 'azure-storage-blob', '~> 2.0', require: false
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'webdrivers'
end

# O-Auth
gem 'omniauth'
gem 'omniauth-azure-activedirectory-v2', '~> 2.1'
gem 'omniauth-github', '~> 2.0'
gem 'omniauth-google-oauth2', '~> 1.1'
gem 'omniauth-linkedin-openid'
gem 'omniauth-rails_csrf_protection'

# Notifications
gem 'noticed', '~> 1.6'

# DB Performance
gem 'benchmark', '~> 0.2.1'
gem 'bullet', '~> 7.0'

gem 'activerecord-import', '~> 1.4'

# Pagination & Querying
gem 'actiontext'
gem 'composite_primary_keys'
gem 'dalli'
gem 'geocoder'
gem 'iso_country_codes'
gem 'kaminari'
gem 'pg_search'
gem 'trix'

# Rich-Text Support
gem 'actionpack', '~> 7.0.8.7'
gem 'activesupport', '>= 7.0.7.1'
gem 'nokogiri', '>= 1.18.3'

# Payments and Subscriptions
gem 'pay', '~> 7.0'
gem 'stripe', '~> 12.5'

# Enable Soft Delete
gem 'paranoia', '~> 2.6'

gem 'faraday', '~> 1.0'

gem 'tempfile', '~> 0.2.1'

# Security and monitoring
gem 'devise'
gem 'newrelic_rpm'
gem 'notable', '~> 0.5.2'
gem 'rack-attack'
gem 'rack-protection'
gem 'rails_admin', '~> 3.0'
gem 'rails-controller-testing', '~> 1.0'

gem 'rails-healthcheck', '~> 1.4'

# enable precommit
gem 'attr_encrypted', '~> 4.0'

gem 'cssbundling-rails'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'stackprof'
