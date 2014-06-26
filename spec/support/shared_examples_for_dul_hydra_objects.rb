require 'support/shared_examples_for_describables'
require 'support/shared_examples_for_governables'
require 'support/shared_examples_for_access_controllables'
require 'support/shared_examples_for_has_properties'

shared_examples "a DulHydra object" do

  it_behaves_like "a describable object"
  it_behaves_like "a governable object"
  it_behaves_like "an access controllable object"
  it_behaves_like "an object that has properties"

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
  
end
