shared_examples "a describable object" do
  before do
    @identifier = "test010010010"
    @title = "Describable Object"
    @describable = described_class.create
  end
  after do
    @describable.delete
  end
  context "having an identifier" do
    before do
      @describable.identifier = @identifier
      @describable.save
    end
    it "should be findable by identifier" do
      described_class.find_by_identifier(@identifier).should include(@describable)
    end
  end
end
