module DulHydra
  module Validations
    extend ActiveSupport::Concern

    module ClassMethods
      def validates_uniqueness_of *attr_names
        options = attr_names.extract_options!
        options.merge!(attributes: attr_names)
        validates_with UniquenessValidator, options
      end
    end

  end
end
