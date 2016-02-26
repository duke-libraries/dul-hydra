source 'http://rubygems.org'

gem 'rails', '~> 4.1.13'
gem 'blacklight', '5.16'
gem 'hydra-head', '~> 9.5'
gem 'ddr-alerts', '~> 1.0.0'
gem 'virtus', '~> 1.0.5'
gem 'ddr-batch', '2.0.0.beta.4'
gem 'ddr-models', '3.0.0.beta.13'
gem 'devise'
gem 'deprecation'
gem 'fedora-migrate', github: 'projecthydra-labs/fedora-migrate', ref: '757504b6443bc39fae02882b27e33e1aa9204fdb'
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
gem 'rubyzip'
gem 'paperclip', '~> 4.2.0'

# Filesystem representation
gem 'rubytree'

group :development, :test do
  gem 'sqlite3'
  gem 'jettywrapper', '~> 2.0'
  gem 'rubydora', '1.8.1'
end

group :test do
  gem 'orderly'
  gem 'capybara', '~> 2.0'
  gem 'rspec-rails', '~> 3.0.0'
  gem 'rspec-its'
  gem 'equivalent-xml'
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~> 4.4'
  gem 'rdf-isomorphic'
end

group :production do
  gem 'mysql2'
end

gem 'sass-rails', '~> 5.0.4'
gem 'jquery-rails'
gem 'uglifier', '~> 1.3.0'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
