require 'spec_helper'
require 'support/shared_examples_for_repository_controllers'

def create_item
  post :create, parent: collection, item: {title: "New Item", description: "Member of a collection"}
end

describe ItemsController do

  let(:user) { FactoryGirl.create(:user) }

  before { sign_in user }

  after do
    ActiveFedora::Base.destroy_all
    User.destroy_all
    EventLog.destroy_all
  end
  
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
        get :new, parent: collection
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
        get :new, parent: collection
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
