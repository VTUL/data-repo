ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
ActiveRecord::Migration.check_pending!

require 'coveralls'
Coveralls.wear! 'rails'

require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'phantomjs'
require 'factory_girl_rails'
require 'devise'
require 'active_fedora/cleaner'

class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end

if defined?(ClamAV)
  ClamAV.instance.loaddb
else
  class ClamAV
    include Singleton
    def scanfile(_f)
      0
    end

    def loaddb
      nil
    end
  end
end

Resque.inline = Rails.env.test?

OmniAuth.config.test_mode = true

$in_travis = !ENV['TRAVIS'].nil? && ENV['TRAVIS'] == 'true'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, phantomjs: Phantomjs.path)
end
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :poltergeist
Capybara.default_max_wait_time = $in_travis ? 30 : 15
Capybara.server = :webrick

RSpec.configure do |config|
  config.include Warden::Test::Helpers
  config.include Devise::TestHelpers, type: :controller
  config.include Devise::TestHelpers, type: :view
  config.include FactoryGirl::Syntax::Methods

  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.fixture_path = File.expand_path("../fixtures", __FILE__)

  config.use_transactional_fixtures = false

  config.before :suite do
    Warden.test_mode!
    DatabaseCleaner.clean_with :truncation
  end

  config.around(:each, js: true, type: :feature) do |example|
    # Forces all threads to share the same connection. This works on
    # Capybara because it starts the web server in a thread.
    ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
    example.run
    ActiveRecord::Base.shared_connection = nil
  end

  config.before :each do |example|
    unless example.metadata[:type] == :view || example.metadata[:no_clean]
      ActiveFedora::Cleaner.clean!
    end

    DatabaseCleaner.strategy = :transaction
    if example.metadata[:type] == :feature && !Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :truncation
    end

    DatabaseCleaner.start

    OmniAuth.config.mock_auth[:cas] = nil
  end

  config.append_after :each do
    DatabaseCleaner.clean
    Warden.test_reset!
  end
end
