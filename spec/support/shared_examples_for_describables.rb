shared_examples "a describable object" do
  context "having an identifier" do
    let!(:object) { described_class.create(:identifier => 'id001') }
    after { object.delete }
    it "should be findable by identifier" do
      described_class.find_by_identifier('id001').should include(object)
    end
  end
end
