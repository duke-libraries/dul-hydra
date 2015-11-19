module DulHydra::Reports
  class IsMemberOfCollectionFilter < DynamicFilter

    def initialize(pid)
      self.clauses = [
        raw_query(Ddr::Index::Fields::IS_MEMBER_OF_COLLECTION, "info:fedora/#{pid}")
      ]
    end

  end
end
