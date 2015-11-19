module DulHydra
  module Reports
    extend ActiveSupport::Autoload

    autoload :CollectionReport
    autoload :Column
    autoload :Columns
    autoload :GetResults
    autoload :GetTotal
    autoload :Report

    autoload_under 'filters' do
      autoload :DynamicFilter
      autoload :Filter
      autoload :HasContentFilter
      autoload :IsGovernedByFilter
      autoload :IsMemberOfCollectionFilter
      autoload :StaticFilter
    end

  end
end
