module DulHydra::Reports
  class CollectionReport < Report

    def initialize(pid)
      self.filters += [ IsGovernedByFilter.new(pid) ]
    end

  end
end
