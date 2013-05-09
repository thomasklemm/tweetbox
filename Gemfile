source 'https://rubygems.org'

# Ruby version on Heroku
ruby '1.9.3'

# Puma (App server)
gem 'puma', '>= 2.0.0'

# Rails
gem 'rails', '3.2.13'

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

# Rack Timeout
gem 'rack-timeout'

# Devise (User authentication)
gem 'devise'

# Omniauth for Twitter (Authenticating Twitter accounts)
gem 'omniauth-twitter'

# Pundit (Authorization)
gem 'pundit'

# Strong parameters (Mass assignment protection)
gem 'strong_parameters'

# Virtus (Attributes on steroids)
gem 'virtus'

# Workflow (State machine library)
gem 'workflow'

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

# Gems used only for assets and not required
#   in production environments by default.
group :assets do
  # Stylesheets
  # Sass and Compass
  gem 'sass-rails'
  gem 'compass-rails'

  # Bourbon (SASS Mixins)
  # Neat (Semantic Grids)
  gem 'bourbon'
  gem 'neat'

  # Javascripts
  gem 'coffee-rails'
  gem 'uglifier'

  # Packaged plugins
  gem 'select2-rails'

  # Font Awesome (Icon font)
  gem 'font-awesome-rails'
end

group :development do
  # Annotate Models (Adds schema info for models to matching files)
  #  Note: master is currently 2.6.0.beta1; gem has not received updates in a while
  gem 'annotate', github: 'ctran/annotate_models'

  # Pry (A great console, replacement for IRB in development)
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

group :staging, :production do
  # Memcached using Memcachier on Heroku
  gem 'memcachier'
  gem 'dalli'

  # New Relic (Server monitoring)
  gem 'newrelic_rpm'

  # Sentry (Error notifications)
  gem 'sentry-raven', github: 'getsentry/raven-ruby'

  # Lograge (Logging)
  gem 'lograge'
end
