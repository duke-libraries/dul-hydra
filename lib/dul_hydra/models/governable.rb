module DulHydra::Models
  module Governable
    extend ActiveSupport::Concern

    included do
      # adds isGovernedBy relationship to object
      belongs_to :admin_policy, :property => :is_governed_by
      #before_save :require_apo
    end

    def set_default_apo
      self.admin_policy = AdminPolicy.default_apo
    end

    def set_default_apo!
      set_default_apo
      save!
    end

    # protected

    # def require_apo
    #   if self.new_object? && self.admin_policy.nil? && self.permissions.empty?
    #     self.admin_policy = AdminPolicy.default_apo
    #   end
    # end

  end
end
