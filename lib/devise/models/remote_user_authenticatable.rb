require 'devise/strategies/remote_user_authenticatable'
require 'bcrypt'

module Devise::Models
  module RemoteUserAuthenticatable
    extend ActiveSupport::Concern

    # def active_for_authentication?
    #   super && request.env['REMOTE_USER'].present?
    # end

    module ClassMethods

      def find_for_remote_user_authentication(remote_user)
        find_for_authentication(:email => remote_user)
      end

      def find_or_create_for_remote_user_authentication(remote_user)
        resource = find_for_remote_user_authentication(remote_user)
        if !resource # auto-create
          resource = new.tap do |r|
            r.email = remote_user
            r.password_confirmation = r.password = BCrypt::Password.create(SecureRandom.hex(16))
            r.save!
          end
        end
        resource
      end

    end

  end
end
