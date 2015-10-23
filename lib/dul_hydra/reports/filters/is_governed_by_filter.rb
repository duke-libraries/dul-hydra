module DulHydra::Reports
  class IsGovernedByFilter < DynamicFilter

    def initialize(pid)
      self.clauses = [
        raw_query(Ddr::Index::Fields::IS_GOVERNED_BY, "info:fedora/#{pid}")
      ]
    end

  end
end
