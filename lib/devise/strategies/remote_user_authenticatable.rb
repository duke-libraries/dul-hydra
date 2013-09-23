require 'devise/strategies/authenticatable'

module Devise::Strategies
  class RemoteUserAuthenticatable < Authenticatable

    def valid?
      remote_user_id.present?
    end

    def authenticate!
      resource = mapping.to.find_or_create_for_remote_user_authentication(remote_user_id)
      resource ? success!(resource) : fail
    end

    protected

    def remote_user_id
      env['REMOTE_USER']
    end

  end
end

Warden::Strategies.add(:remote_user_authenticatable, Devise::Strategies::RemoteUserAuthenticatable)
