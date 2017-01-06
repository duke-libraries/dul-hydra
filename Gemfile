source 'https://rubygems.org'
ruby '2.3.1'

gem 'rails', '4.2.7'
gem 'hydra-head', '~> 7.2.0'
gem 'ddr-alerts', github: 'duke-libraries/ddr-alerts', ref: 'a5840f86d808e4789011cc3d054ac7322b5f23ee'
gem 'ddr-batch', github: 'duke-libraries/ddr-batch', ref: '6da06a1a14451d6e360db7f15ada23123dc4452c'
gem 'ddr-models', github: 'duke-libraries/ddr-models', ref: 'cc9ccc5af8b82f56f9c58e0786ac16623b119970'
gem 'rubydora', '>= 1.8.1'
gem 'devise'
gem 'deprecation'
gem 'virtus', '~> 1.0.5'

gem 'log4r'

# Background processing
gem 'resque', '1.25.2'
gem 'resque-pool', '~> 0.6.0'
gem 'nest', '1.1.2'

# ExecJS runtime
gem 'therubyracer', '~> 0.11.3', require: 'v8', group: :production

# For mapping file extensions to MIME types
gem 'mime-types', '~> 2.6'

# Export sets
gem 'rubyzip', '< 1.0.0'
gem 'paperclip', '~> 4.2.0'

# Filesystem representation
gem 'rubytree'

# Rails 4.2+
gem 'responders', '~> 2.0'

gem 'web-console', '~> 2.0', group: :development

group :development, :test do
  gem 'sqlite3'
  gem 'jettywrapper', '~> 1.8'
end

group :test do
  gem 'orderly'
  gem 'capybara', '~> 2.0'
  gem 'rspec-rails', '~> 3.0'
  gem 'rspec-its'
  gem 'equivalent-xml'
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~> 4.4'
end

group :production do
  gem 'mysql2'
end

gem 'sass-rails'
gem 'jquery-rails'
gem 'uglifier', '~> 1.3.0'
gem 'sprockets-rails', '>= 2.1.4'
