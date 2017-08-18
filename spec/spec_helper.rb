# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)

require 'rspec/rails'
require 'rspec/matchers' # req by equivalent-xml custom matcher `be_equivalent_to`
require 'equivalent-xml/rspec_matchers'
require 'capybara/rails'
require 'capybara/rspec'
require 'dul_hydra'
require 'database_cleaner'
require "ddr/auth/test_helpers"
require "resque"

Deprecation.default_deprecation_behavior = :silence

Resque.inline = true

DatabaseCleaner.strategy = :truncation

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.include ActionDispatch::TestProcess
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Devise helpers
  config.include Devise::TestHelpers, type: :controller

  # Warden helpers
  config.include Warden::Test::Helpers, type: :feature
  Warden.test_mode!

  config.before(:suite) do
    DatabaseCleaner.clean
    ActiveFedora::Base.destroy_all
    Ddr::Datastreams::ExternalFileDatastream.file_store = Dir.mktmpdir
  end
  config.after(:suite) do
    FileUtils.rm_rf Ddr::Datastreams::ExternalFileDatastream.file_store
  end

  config.before(:each) do
    allow(Ddr::Models::AdminSet).to receive(:find_by_code) { nil }
    allow(Ddr::Models::AdminSet).to receive(:find_by_code).with('foo') {
      double('Ddr::Models::AdminSet', code: 'foo', title: 'Foo Admin Set')
    }
  end
  config.after(:each) { ActiveFedora::Base.destroy_all }
  config.after(:each, type: :feature) { Warden.test_reset! }

  # Redirect all output to file
  # config.output = File.open(File.join(Rails.root, 'log', 'rspec_output.txt'), 'w')
end

DulHydra.host_name = 'localhost'
DulHydra.auto_update_parent_structure = false
