require 'devise/strategies/remote_user_authenticatable'

module Devise::Models
  module RemoteUserAuthenticatable
    extend ActiveSupport::Concern

    module ClassMethods

      def find_for_remote_user_authentication(remote_user)
        find_for_authentication(:email => remote_user)
      end

      def find_or_create_for_remote_user_authentication(remote_user)
        resource = find_for_remote_user_authentication(remote_user)
        if !resource # auto-create
          resource = new.tap do |r|
            r.email = remote_user
            r.password_confirmation = r.password = SecureRandom.hex(16)
            r.save!
          end
        end
        resource
      end

    end

  end
end
