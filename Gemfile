source 'https://rubygems.org'

# Ruby version on Heroku
ruby '2.0.0'

# Puma (App server)
gem 'puma'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

# Postgres database connector
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# Compass
# TODO: Remove
# gem 'compass-rails', github: 'milgner/compass-rails', branch: 'rails4'

# jQuery Rails (jQuery adapter for Rails)
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Packaged plugins
gem 'bootstrap-sass', '~> 2.3.2.0'
gem 'select2-rails'

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
# gem 'strong_parameters'

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
# REVIEW: DEPENDS ON RAILS 3.2
# gem 'postgres_ext'

# Enumerated attributes
gem 'enumerize'

# Pusher (Live updates)
gem 'pusher'

# Pry Console
gem 'pry'
gem 'pry-rails', group: :development

group :development do
  # Letter Opener (Previews ActionMailer emails in development)
  gem 'letter_opener'

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
  gem 'shoulda-matchers', github: 'thoughtbot/shoulda-matchers', branch: 'dp-rails-four'
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
  # Heroku 12factor gem
  gem 'rails_12factor'

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

# Use debugger
# gem 'debugger', group: [:development, :test]
