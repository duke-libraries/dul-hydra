module DulHydra::Models
  module RelationshipAliases
    extend ActiveSupport::Concern

    module ClassMethods
      def belongs_to_alias(from, to, writer=true)
        alias_method from, to
        alias_method "#{from}_id", "#{to}_id"
        alias_method "#{from}=", "#{to}=" if writer
      end

      def has_many_alias(from, to)
        alias_method from, to
        alias_method "#{from.singularize}_ids", "#{to.singularize}_ids"
      end

      def has_parent(name, writer=true)
        self.belongs_to_alias :parent, name, writer
      end
    end

  end
end
