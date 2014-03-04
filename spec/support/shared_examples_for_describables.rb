shared_examples "a describable object" do
  let!(:object) do
    described_class.new.tap do |obj|
      obj.title = 'Describable'
      obj.identifier = 'id001'
      obj.save(validate: false)
    end
  end
  after { object.destroy }
  context "having an identifier" do
    it "should be findable by identifier" do
      described_class.find_by_identifier('id001').should include(object)
    end
  end
end
