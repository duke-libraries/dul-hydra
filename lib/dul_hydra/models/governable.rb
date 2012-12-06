module DulHydra::Models
  module Governable
    extend ActiveSupport::Concern

    included do
      # adds isGovernedBy relationship to object
      belongs_to :admin_policy, :property => :is_governed_by
    end

    def set_default_apo
      self.admin_policy = AdminPolicy.get_default_apo
    end

  end
end
