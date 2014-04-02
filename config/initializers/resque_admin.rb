module DulHydra
  class ResqueAdmin
    def self.matches?(request)
      current_user = request.env['warden'].user
      return false if current_user.blank?
      # TODO code a group here that makes sense
      #current_user.groups.include? 'umg/up.dlt.scholarsphere-admin'
      # Ability.new(current_user).can? :manage, Resque
      # temporarily bypass constraint until ability_groups refactoring merged
      return true
    end
  end
end