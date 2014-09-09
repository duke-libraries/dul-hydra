require 'spec_helper'

describe DulHydra::Services::IdService do

  before { FileUtils.rm(DulHydra.minter_statefile) if File.exists?(DulHydra.minter_statefile)}
  after { FileUtils.rm(DulHydra.minter_statefile) }
  
  context "identifier format" do
    before { allow(DulHydra::Services::IdService).to receive(:noid_template).and_return("x.rddeeddeek") }
    it "should mint identifiers of the appropriate format" do
      expect(DulHydra::Services::IdService.mint).to match(/x\d\d\w\w\d\d\w\w\w/)
    end
  end
  
  context "duplicate identifiers" do
    before do
      allow(DulHydra::Services::IdService).to receive(:noid_template).and_return(".rd")
      allow(ActiveFedora::Base).to receive(:exists?).with(DulHydra::IndexFields::PERMANENT_ID => '0').and_return(true)
      allow(ActiveFedora::Base).to receive(:exists?).with(DulHydra::IndexFields::PERMANENT_ID => '1').and_return(true)
      allow(ActiveFedora::Base).to receive(:exists?).with(DulHydra::IndexFields::PERMANENT_ID => '2').and_return(true)
      allow(ActiveFedora::Base).to receive(:exists?).with(DulHydra::IndexFields::PERMANENT_ID => '3').and_return(true)
      allow(ActiveFedora::Base).to receive(:exists?).with(DulHydra::IndexFields::PERMANENT_ID => '4').and_return(true)
      allow(ActiveFedora::Base).to receive(:exists?).with(DulHydra::IndexFields::PERMANENT_ID => '5').and_return(false)
      allow(ActiveFedora::Base).to receive(:exists?).with(DulHydra::IndexFields::PERMANENT_ID => '6').and_return(true)
      allow(ActiveFedora::Base).to receive(:exists?).with(DulHydra::IndexFields::PERMANENT_ID => '7').and_return(true)
      allow(ActiveFedora::Base).to receive(:exists?).with(DulHydra::IndexFields::PERMANENT_ID => '8').and_return(true)
      allow(ActiveFedora::Base).to receive(:exists?).with(DulHydra::IndexFields::PERMANENT_ID => '9').and_return(true)
    end
    it "should not mint an already existing identifier" do
      expect(DulHydra::Services::IdService.mint).to eq('5') 
    end
  end
  
end