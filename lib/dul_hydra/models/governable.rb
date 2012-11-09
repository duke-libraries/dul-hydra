module DulHydra::Models
  module Governable
    extend ActiveSupport::Concern
    included do
      belongs_to :admin_policy, :property=>:is_governed_by
    end
  end
end
