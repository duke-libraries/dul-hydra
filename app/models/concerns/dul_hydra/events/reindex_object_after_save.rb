module DulHydra
  module Events
    module ReindexObjectAfterSave
      extend ActiveSupport::Concern

      included do
        after_save :reindex_object, unless: "object.nil?" # in case saved with validate: false
      end
    
      protected
      
      def reindex_object
        object.update_index
      end

    end
  end
end
