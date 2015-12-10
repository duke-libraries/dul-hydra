require 'spec_helper'

module DulHydra::Reports
  RSpec.describe Columns do

    Ddr::Index::Fields.constants(false).each do |const|
      specify {
        expect(Columns.const_defined?(const, false)).to be true
      }
    end

  end
end
