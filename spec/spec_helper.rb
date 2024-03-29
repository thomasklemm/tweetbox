# SimpleCov settings
# require 'simplecov'
# SimpleCov.start 'rails'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Custom pundit matchers from the gem
require 'pundit/rspec'

# Sidekiq
require 'sidekiq/testing'

# Requires namespaced models and controllers
Dir[Rails.root.join("app/controllers/**/*.rb")].each {|f| require f}
Dir[Rails.root.join("app/models/**/*.rb")].each {|f| require f}

# Requires lib directory
Dir[Rails.root.join("lib/**/*.rb")].each {|f| require f}

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Render views globally
  config.render_views

  # Focus on specs with focus: true and :focus metadata
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true

  # Devise test helpers in controllers
  config.include Devise::TestHelpers, type: :controller

  # Fail specs after the first failing spec
  # config.fail_fast = true


  # http://labs.goclio.com/tuning-ruby-garbage-collection-for-rspec/
  # Quick hack to see what our peak number of objects on the heap is
  # heap_live_num = 0
  # config.after(:each) do
  #   heap_live_num = [heap_live_num, GC.stat[:heap_live_num]].max
  # end
  # config.after(:suite) do
  #   puts "\nMAX HEAP OBJECT COUNT: #{heap_live_num}"
  # end
end

require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
Capybara.default_wait_time = 1
# Capybara.default_host = 'lvh.me:7000'
