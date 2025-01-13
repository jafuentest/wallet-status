source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.0.8'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.6'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# New Relic
gem 'newrelic_rpm'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.2'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem 'kredis'
# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem 'bcrypt', '~> 3.1.7'

# Binance
gem 'binance-connector-ruby', github: 'jafuentest/binance-connector-ruby'
# User registrations
gem 'devise'
# Background jobs
gem 'delayed_job_active_record'
gem 'delayed_job_recurring'
gem 'delayed-web'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem 'jsbundling-rails'
# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem 'cssbundling-rails'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem 'image_processing', '~> 1.2'

# Make parallel requests
gem 'parallel', '~> 1.22'

# Nokogiri requires glibc >= 2.28 starting from version 1.18
gem 'nokogiri', '< 1.18'

# Just to silence ruby 3.5 warnings, may remove some in the future
gem 'bigdecimal'
gem 'fiddle'
gem 'logger'
gem 'ostruct'
gem 'rdoc'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]

  # Code style check
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'

  gem 'rspec'
end

group :development do
  # Start all server components in a single terminal
  gem 'foreman'

  # Use console on exceptions pages [https://github.com/rails/web-console]
  # gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  gem 'rack-mini-profiler'

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem 'spring'

  # Deployment support
  gem 'capistrano'
  gem 'capistrano3-puma'
  gem 'capistrano-bundler'
  gem 'capistrano-delayed-job'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'

  # Add database schema to models
  gem 'annotate', '~> 3.2'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  # gem 'capybara'
  # gem 'selenium-webdriver'
  # gem 'webdrivers'
end
