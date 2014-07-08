module DulHydra
  class ResqueAdmin
    def self.matches?(request)
      current_user = request.env['warden'].user
      Ability.new(current_user).can? :manage, Queue
    end
  end
end