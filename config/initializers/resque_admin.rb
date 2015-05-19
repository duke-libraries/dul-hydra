module DulHydra
  class ResqueAdmin
    def self.matches?(request)
      request.env['warden'].authenticated?(:superuser)
    end
  end
end
