source 'https://rubygems.org'
ruby '2.1.5'

gem 'rake', '~> 11.3.0'
gem 'rails', '4.1.16'
gem 'hydra-head', '7.2.2'
gem 'blacklight', '5.19.2'
gem 'ddr-alerts', '~> 1.0.0'
gem 'ddr-batch', '1.2.0.rc4'
gem 'ddr-models', '2.6.0.rc4'
gem 'rubydora', '>= 1.9.1'
gem 'devise'
gem 'deprecation'
gem 'virtus', '~> 1.0.5'

gem 'log4r'

# Background processing
gem 'resque', '1.25.2'
gem 'resque-pool', '~> 0.6.0'
gem 'nest', '1.1.2'

# ExecJS runtime
gem 'therubyracer', require: 'v8', group: :production

# For mapping file extensions to MIME types
gem 'mime-types', '~> 2.6'

# Export sets
gem 'rubyzip', '< 1.0.0'
gem 'paperclip', '~> 4.2'

# Filesystem representation
gem 'rubytree'

group :development, :test do
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
  gem 'mysql2', '~> 0.3.21'
end

gem 'sass-rails'
gem 'jquery-rails'
gem 'uglifier'
