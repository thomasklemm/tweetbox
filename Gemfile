source 'https://rubygems.org'

# Ruby version on Heroku
ruby '2.0.0'

# Puma (App server)
gem 'puma'

# Rails
gem 'rails', '3.2.14'

# Postgres database connector
gem 'pg'

# jQuery Rails (jQuery adapter for Rails)
gem 'jquery-rails'

# High Voltage (Static pages in Rails)
gem 'high_voltage'

# Slim (Great templating engine)
gem 'slim-rails'

# Figaro (Credential management in config/application.yml)
gem 'figaro'

# Devise (User authentication)
gem 'devise', '>= 3.0.0'

# Omniauth for Twitter (Authenticating Twitter accounts)
gem 'omniauth-twitter'

# Pundit (Authorization)
gem 'pundit'

# Strong parameters (Mass assignment protection)
gem 'strong_parameters'

# Virtus (Attributes on steroids)
gem 'virtus'

# Transitions (State machine)
gem 'transitions', require: ['transitions', 'active_model/transitions'], github: 'troessner/transitions'

# Twitter (Twitter REST API client)
gem 'twitter'

# Sidekiq (Background jobs)
gem 'sidekiq'

# Sinatra (for Sidekiq web interface)
gem 'sinatra'

# Clockwork (Scheduler for recurring jobs)
gem 'clockwork'

# Draper (Presenters / Decorators)
gem 'draper'

# Oj (Optimized JSON Parser)
gem 'oj'

# Twitter Text (Autolinking tweet urls and more)
gem 'twitter-text'

# Use arrays and more in Postgres
gem 'postgres_ext'

# Enumerated attributes
gem 'enumerize'

# Pusher (Live updates)
gem 'pusher'

# Gems used only for assets and not required
#   in production environments by default.
group :assets do
  # Stylesheets
  # Sass and Compass
  gem 'sass-rails'
  gem 'compass-rails'

  # Javascripts
  gem 'coffee-rails'
  gem 'uglifier'

  # Packaged plugins
  gem 'bootstrap-sass', '~> 2.3.2.0'
  gem 'select2-rails'
end

group :development do
  # Pry (A great console, replacement for IRB in development)
  gem 'pry'
  gem 'pry-rails'

  # Letter Opener (Previews ActionMailer emails in development)
  gem 'letter_opener'

  # Quiet Assets (Mutes asset pipeline logs in development)
  gem 'quiet_assets'

  # Bullet (Finds N+1 queries and more in development)
  gem 'bullet'

  # Better Errors (Debug pages in development)
  gem 'better_errors'
  gem 'binding_of_caller'

  # LiveReload
  gem 'guard-livereload'
  gem 'rack-livereload'
end

group :development, :test do
  gem 'rspec-rails'
end

group :test do
  gem 'shoulda-matchers'
  gem 'fabrication'
  gem 'database_cleaner'
  gem 'mocha'
  gem 'timecop'
  gem 'simplecov', require: false
  gem 'coveralls', require: false
  gem 'capybara-webkit'
  gem 'launchy'
  gem 'webmock'
  gem 'vcr'
end

group :production do
  # Memcached using Memcachier on Heroku
  gem 'memcachier'
  gem 'dalli'

  # New Relic (Server monitoring)
  gem 'newrelic_rpm'

  # Sentry (Error notifications)
  gem 'sentry-raven', github: 'getsentry/raven-ruby'

  # Lograge (Logging)
  gem 'lograge'

  # Rack Timeout
  gem 'rack-timeout'
end
