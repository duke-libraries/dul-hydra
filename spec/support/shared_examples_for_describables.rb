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
  context "descriptive metadata source" do
    context "present in properties" do
      before do
        object.descmetadata_source = 'some_value'
        object.save(validate: false)
      end
      it "should indicate that descriptive metadata is not editable" do
        object.descriptive_metadata_editable?.should eql(false)
      end
    end
    context "not present in properties" do
      it "should indicate that descriptive metadata is editable" do
        object.descriptive_metadata_editable?.should eql(true)        
      end      
    end
  end
end
