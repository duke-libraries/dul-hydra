require 'support/shared_examples_for_describables'
require 'support/shared_examples_for_governables'
require 'support/shared_examples_for_access_controllables'
require 'support/shared_examples_for_has_preservation_events'
require 'support/shared_examples_for_has_properties'
require 'support/shared_examples_for_has_thumbnail'

shared_examples "a DulHydra object" do

  it_behaves_like "a describable object"
  it_behaves_like "a governable object"
  it_behaves_like "an access controllable object"
  it_behaves_like "an object that has preservation events"
  it_behaves_like "an object that has properties"
  it_behaves_like "an object that has a thumbnail"

  context "#title_display" do
    subject { object.title_display }
    context "has title" do
      let(:object) { described_class.new(:title => 'Title') }
      it { should eq('Title') }
    end
    context "has no title, has identifier" do
      let(:object) { described_class.new(:identifier => 'id001') }
      it { should eq('id001') }
    end
    context "has no title, has no identifier" do
      let(:object) { described_class.new(:pid => 'duke:test') }
      it { should eq("[duke:test]") }
    end
  end
  
  context "#validate_checksums" do
    let(:object) do
      described_class.new.tap do |obj|
        obj.title = 'Title'
        obj.save(validate: false)
      end
    end
    after { object.destroy }
    it "should return a boolean success/failure flag and hash of datastream profiles" do
      outcome, detail = object.validate_checksums
      outcome.should be_true
      detail.should be_kind_of(Hash)
      object.datastreams.each do |dsid, ds|
        unless ds.profile.empty?
          detail[dsid].should eq(ds.profile)
        end
      end
    end
  end

end
