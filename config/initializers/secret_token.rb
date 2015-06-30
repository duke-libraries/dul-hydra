# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
DulHydra::Application.config.secret_token = if Rails.env.production?
                                              ENV['SECRET_TOKEN']
                                            else
                                              SecureRandom.hex(64)
                                            end

# For Rails 4 -- cf. http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#wiki-upgrading-from-rails-3-2-to-rails-4-0
DulHydra::Application.config.secret_key_base = if Rails.env.production?
                                                 ENV['SECRET_KEY_BASE']
                                               else
                                                 SecureRandom.hex(64)
                                               end
