require 'spec_helper'

module DulHydra

  shared_examples "a permanently identified object" do
    it "should have a permanent id" do
      expect(object.permanent_id).to_not be_nil
    end
    it "should have an appropriate update event" do
      expect(object.update_events.map(&:summary)).to include("Assigned permanent ID")
    end
    it "should be a referent for the permanent id" do
      expect(MintedId.find_by(minted_id: object.permanent_id).referent).to eql(object.pid)
    end
  end

  describe PermanentIdentification, type: :model do

    before { skip }

    before(:all) do
      class PermanentlyIdentifiable < ActiveFedora::Base
        include DulHydra::Describable
        include DulHydra::HasProperties
        include DulHydra::PermanentIdentification
        include DulHydra::EventLoggable
      end
    end

    context "creating new object" do
      let(:object) { PermanentlyIdentifiable.create }
      it_behaves_like "a permanently identified object"
    end
    
    context "saving new object" do
      let(:object) { PermanentlyIdentifiable.new }
      before { object.save }
      it_behaves_like "a permanently identified object"
    end
    
    context "saving an existing object" do
      let(:object) { PermanentlyIdentifiable.create }
      it "should keep its existing permanent id" do
        perm_id = object.permanent_id
        object.title = [ "New Title" ]
        object.save
        expect(object.permanent_id).to eq(perm_id)
      end
    end
    
    context "exception during permanent id minting" do
      let(:object) { PermanentlyIdentifiable.create }
      before { allow(DulHydra::Services::IdService).to receive(:mint).and_raise(Exception) }
      it "should have a failure update event" do
        expect(object.update_events.last.summary).to eq("Assigned permanent ID")
        expect(object.update_events.last.outcome).to eq(Event::FAILURE)
      end
    end

  end

end