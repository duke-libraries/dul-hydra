require 'spec_helper'

describe Ddr::Services::IdService do

  before { FileUtils.rm(Ddr::Models.minter_statefile) if File.exists?(Ddr::Models.minter_statefile)}
  after { FileUtils.rm(Ddr::Models.minter_statefile) }
  
  context "identifier format" do
    before { allow(Ddr::Services::IdService).to receive(:noid_template).and_return("x.rddeeddeek") }
    it "should mint identifiers of the appropriate format" do
      expect(Ddr::Services::IdService.mint).to match(/x\d\d\w\w\d\d\w\w\w/)
    end
  end
  
  context "duplicate identifiers" do
    before do
      allow(Ddr::Services::IdService).to receive(:noid_template).and_return(".rd")
      Ddr::Models::MintedId.create(minted_id: '0')
      Ddr::Models::MintedId.create(minted_id: '1')
      Ddr::Models::MintedId.create(minted_id: '2')
      Ddr::Models::MintedId.create(minted_id: '3')
      Ddr::Models::MintedId.create(minted_id: '4')
      Ddr::Models::MintedId.create(minted_id: '6')
      Ddr::Models::MintedId.create(minted_id: '7')
      Ddr::Models::MintedId.create(minted_id: '8')
      Ddr::Models::MintedId.create(minted_id: '9')
    end
    it "should not mint an already existing identifier" do
      expect(Ddr::Services::IdService.mint).to eq('5') 
    end
  end
  
end