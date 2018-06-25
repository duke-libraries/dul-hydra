DulHydra::Application.config.secret_key_base = if Rails.env.production?
                                                 ENV['SECRET_KEY_BASE']
                                               else
                                                 SecureRandom.hex(64)
                                               end
