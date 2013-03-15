require 'spec_helper'

describe "DulHydra::Models::Base" do
  context "#title_display" do
    subject { object.title_display }
    context "has title" do
      let(:object) { DulHydra::Models::Base.new(:title => 'Title') }
      it { should eq('Title') }
    end
    context "has no title, has identifier" do
      let(:object) { DulHydra::Models::Base.new(:identifier => 'id001') }
      it { should eq('id001') }
    end
    context "has no title, has no identifier" do
      let(:object) { DulHydra::Models::Base.new(:pid => 'duke:test') }
      it { should eq("[duke:test]") }
    end
  end
end
