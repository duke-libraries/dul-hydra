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

Resque.inline = true

DatabaseCleaner.strategy = :truncation

# XXX Hack to bypass file characterization
# See https://github.com/duke-libraries/ddr-models/issues/315
Ddr::Jobs::FitsFileCharacterization.class_eval do
  def self.perform(pid); end
end

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
    Ddr::Models.configure do |config|
      config.external_file_store = Dir.mktmpdir
      config.multires_image_external_file_store = Dir.mktmpdir
      config.external_file_subpath_pattern = "--"
    end
  end
  config.after(:suite) do
    if Ddr::Models.external_file_store && Dir.exist?(Ddr::Models.external_file_store)
      FileUtils.remove_entry_secure(Ddr::Models.external_file_store)
    end
    if Ddr::Models.multires_image_external_file_store && Dir.exist?(Ddr::Models.multires_image_external_file_store)
      FileUtils.remove_entry_secure(Ddr::Models.multires_image_external_file_store)
    end
  end
  config.after(:each) { ActiveFedora::Base.destroy_all }
  config.after(:each, type: :feature) { Warden.test_reset! }

  # Redirect all output to file
  # config.output = File.open(File.join(Rails.root, 'log', 'rspec_output.txt'), 'w')
end
