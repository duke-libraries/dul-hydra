require 'devise/strategies/authenticatable'

module Devise::Strategies
  class RemoteUserAuthenticatable < Authenticatable

    def valid?
      env['REMOTE_USER'].present?
    end

    def authenticate!
      resource = mapping.to.find_or_create_for_remote_user_authentication(env['REMOTE_USER'])
      resource ? success!(resource) : fail
    end

  end
end

Warden::Strategies.add(:remote_user_authenticatable, Devise::Strategies::RemoteUserAuthenticatable)
