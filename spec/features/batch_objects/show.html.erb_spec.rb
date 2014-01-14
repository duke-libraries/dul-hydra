require 'spec_helper'
require 'helpers/user_helper'

describe "batch_objects/show.html.erb", batch: true do
  
  let(:batch) { FactoryGirl.create(:batch_with_generic_ingest_batch_objects) }
  
  after do
    batch.batch_objects.each do |batch_object|
      batch_object.batch_object_relationships.each do |r|
        begin
          ActiveFedora::Base.find(r[:object], :cast => true).destroy if r[:name].eql?("parent")
        rescue ActiveFedora::ObjectNotFoundError
          nil
        end
        AdminPolicy.find(r[:object]).destroy if r[:name].eql?("admin_policy")
      end
    end
    batch.user.destroy
    batch.destroy
  end
  
  context "batch object" do
    
    let(:batch_object) { batch.batch_objects.first }
    
    before do
      @admin_policy_pid = @parent_pid = nil
      batch_object.batch_object_relationships.each do |r|
        case r.name
        when DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY
          @admin_policy_pid = r.object
        when DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY
          @parent_pid = r.object
        end
      end      
      login batch.user
      visit(batch_object_path(batch_object))
    end
    
    it "should display information about the batch object" do
      expect(page).to have_text("Batch Object #{batch_object.id}")
      expect(page).to have_link("#{batch.id} (#{batch.name} - #{batch.description})", :href => batch_path(batch))
      expect(page).to have_text(@admin_policy_pid)
      expect(page).to have_text(@parent_pid)
      expect(page).to have_text(DulHydra::Datastreams::DESC_METADATA)
      expect(page).to have_text(DulHydra::Datastreams::CONTENT)
    end
  end
  
end
