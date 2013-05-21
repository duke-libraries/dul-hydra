require "spec_helper"

describe "objects context nav" do
  before { visit fcrepo_admin.object_path(object) }
  after { object.delete }
  context "children" do
    context "object has children" do
      after do
        object.children.each {|c| c.delete}
        object.reload
      end
      context "object has content metadata" do
        let(:object) { FactoryGirl.create(:test_content_metadata_has_children) }
        it "should link to the children path" do
          page.should have_link("Children", :href => children_path(object))
        end
      end
      context "object has no content metadata" do
        let(:object) { FactoryGirl.create(:test_parent_has_children) }
        it "should link to the children association path" do
          page.should have_link("Children", :href => fcrepo_admin.object_association_path(object, 'children'))
        end
      end
    end
    context "object does not have children" do
      let(:object) { FactoryGirl.create(:test_model) }
      it "should not have a children link" do
        page.should_not have_link("Children")
      end
    end
  end
end
