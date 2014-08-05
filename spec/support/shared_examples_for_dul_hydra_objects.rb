require 'support/shared_examples_for_describables'
require 'support/shared_examples_for_governables'
require 'support/shared_examples_for_access_controllables'
require 'support/shared_examples_for_has_properties'

shared_examples "a DulHydra object" do

  it_behaves_like "a describable object"
  it_behaves_like "a governable object"
  it_behaves_like "an access controllable object"
  it_behaves_like "an object that has properties"

  describe "#title_display" do
    let(:object) { described_class.new }
    subject { object.title_display }
    context "has title" do
      before { object.title = [ 'Title' ] }
      it "should return the first title" do
        expect(subject).to eq('Title')
      end
    end
    context "has no title, has identifier" do
      before { object.identifier = [ 'id001' ] }
      it "should return the first identifier" do
        expect(subject).to eq('id001')
      end
    end
    context "has no title, no identifier, has original_filename" do
      before { allow(object).to receive(:original_filename) { "file.txt" } }
      it "should return original_filename" do
        expect(subject).to eq "file.txt"
      end
    end
    context "has no title, no identifier, no original_filename" do
      let(:object) { described_class.new(:pid => 'duke:test') }
      it "should return the PID in square brackets" do
        expect(subject).to eq "[duke:test]"
      end
    end
  end
  
end
