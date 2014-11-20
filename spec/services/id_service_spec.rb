require 'spec_helper'

describe DulHydra::Services::IdService do

  before { skip }

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
      MintedId.create(minted_id: '0')
      MintedId.create(minted_id: '1')
      MintedId.create(minted_id: '2')
      MintedId.create(minted_id: '3')
      MintedId.create(minted_id: '4')
      MintedId.create(minted_id: '6')
      MintedId.create(minted_id: '7')
      MintedId.create(minted_id: '8')
      MintedId.create(minted_id: '9')
    end
    it "should not mint an already existing identifier" do
      expect(DulHydra::Services::IdService.mint).to eq('5') 
    end
  end
  
end