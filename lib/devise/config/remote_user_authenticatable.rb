module Devise
  # request.env key for remote user name
  # Set to 'HTTP_REMOTE_USER' in config/initializers/devise.rb if behind reverse proxy
  mattr_accessor :remote_user_env_key
  @@remote_user_env_key = 'REMOTE_USER'
  
  # request.env key for remote user email address, required for auto-creation
  mattr_accessor :remote_user_email_env_key

  # Enable user auto-creation for remote user
  mattr_accessor :remote_user_autocreate
  @@remote_user_autocreate = false
end
