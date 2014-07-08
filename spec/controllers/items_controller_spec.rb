require 'spec_helper'
require 'support/shared_examples_for_repository_controllers'

def create_item
  post :create, parent_id: collection.pid
end

describe ItemsController, items: true do

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  
  it_behaves_like "a repository object controller" do
    let(:collection) { FactoryGirl.create(:collection) }
    let(:create_object) do
      Proc.new do
        controller.current_ability.can(:add_children, collection)
        create_item
      end
    end
    let(:new_object) do
      Proc.new do
        controller.current_ability.can(:add_children, collection)
        get :new, parent_id: collection.pid
      end
    end
  end

  describe "#new" do
    # see shared examples
    let(:collection) { FactoryGirl.create(:collection) }    
    before { controller.current_ability.can(:create, Item) }
    context "when the user cannot add children to the collection" do
      before { controller.current_ability.cannot(:add_children, collection) }
      it "should be unauthorized" do
        get :new, parent_id: collection.pid
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#create" do
    # see shared examples
    let(:collection) { FactoryGirl.create(:collection) }
    before { controller.current_ability.can(:create, Item) }
    context "when the user cannot add children to the collection" do
      before { controller.current_ability.cannot(:add_children, collection) }
      it "should be unauthorized" do
        create_item
        expect(response.response_code).to eq(403)
      end
    end
  end
end
