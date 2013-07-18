source 'https://rubygems.org'

gem 'rails', '~> 3.2.13'

gem 'sqlite3'
gem 'hydra-head', github: 'projecthydra/hydra-head'
gem 'blacklight', '~> 4.2.1'
gem 'bootstrap-sass' # blacklight 4.0
gem 'unicode'        # blacklight 4.0
gem 'devise'
gem 'fcrepo_admin', github: 'projecthydra/fcrepo-admin'
gem 'active-fedora', '~> 6.4.3'

gem 'log4r'

# ExecJS runtime
gem 'therubyracer', '~> 0.11.3', :require => 'v8'

# For mapping file extensions to MIME types
gem 'mime-types', '~> 1.19'

# Export sets
gem 'rubyzip'
gem 'paperclip', '~> 3.0'

# Image manipulation
gem 'mini_magick'

group :development, :test do
  gem 'rspec-rails' #, '~> 2.12.0'
  gem 'capybara', '~> 2.0'
  gem 'jettywrapper'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'orderly'
  gem 'launchy'
end

group :production do
  gem 'mysql2'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'jquery-rails'
  gem 'uglifier', '~> 1.3.0'
end

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
