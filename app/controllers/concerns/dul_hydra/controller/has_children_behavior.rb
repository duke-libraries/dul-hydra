module DulHydra
  module Controller
    module HasChildrenBehavior
      extend ActiveSupport::Concern

      included do
        helper_method :object_children        
        # XXX Shouldn't have to do this ...
        before_action :object_children, only: :show
      end

    end
  end
end
