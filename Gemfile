source 'https://rubygems.org'
ruby '2.3.1'

gem 'rails', '4.2.7'
gem 'hydra-head', '~> 7.2.0'
gem 'ddr-alerts', git: 'https://github.com/duke-libraries/ddr-alerts', ref: '01408a82f13292b655b3c561688cf824cbd14549'
gem 'ddr-batch', git: 'https://github.com/duke-libraries/ddr-batch', ref: '557268bc77aa8d3aeb72959f02705b157017c50a'
gem 'ddr-models', git: 'https://github.com/duke-libraries/ddr-models', ref: 'e0ed623a3722ca9583f2531f97dd5f20c126293d'
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

# Rails 4.2
gem 'responders', '~> 2.0'
gem 'web-console', '~> 2.0', group: :development
gem 'sprockets-rails', '>= 2.1.4'

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
