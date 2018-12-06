source 'https://rubygems.org'
ruby '2.3.1'

gem 'rails', '4.2.11'

gem 'ddr-alerts', '1.1.0'
gem 'ddr-batch', '1.7.2'
gem 'ddr-models', '2.11.0'

gem 'hydra-head', '7.2.2'
gem 'blacklight', '5.19.2'
gem 'rubydora', '>= 1.9.1'

gem 'devise'
gem 'deprecation'
gem 'virtus', '~> 1.0.5'
gem 'ezid-client', '~> 1.7'
gem 'bagit'
gem 'figaro'

# Background processing
gem 'resque', '1.25.2'
gem 'resque-pool', '~> 0.6.0'
gem 'nest', '1.1.2'

# ExecJS runtime
gem 'therubyracer', require: 'v8', group: :production

# For mapping file extensions to MIME types
gem 'mime-types', '~> 2.6'

gem 'paperclip', '~> 5.2'

# Filesystem representation
gem 'rubytree'

# Icons
gem 'font-awesome-sass', '~> 4.6.2'

# Rails 4.2
gem 'responders', '~> 2.0'
gem 'web-console', '~> 2.0', group: :development
gem 'sprockets-rails', '2.3.3'

group :development, :test do
  gem 'byebug'
  gem 'sqlite3'
  gem 'jettywrapper', '~> 1.8'
end

group :test do
  gem 'orderly'
  gem 'capybara', '~> 2.0'
  gem 'rspec-rails', '~> 3.5'
  gem 'rspec-its'
  gem 'equivalent-xml'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
end

group :production do
  # NOTE: mysql2 version requirement is a Rails runtime dependency defined in
  # active_record/connection_adapters/mysql2_adapter.
  gem 'mysql2', '>= 0.3.13', '< 0.5'
  gem 'passenger'
end

gem 'sass-rails'
gem 'jquery-rails'
gem 'uglifier'
