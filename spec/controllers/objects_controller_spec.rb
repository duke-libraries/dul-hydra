require 'spec_helper'

describe ObjectsController do

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  after { user.delete }

  describe "create actions" do
    before do
      DulHydra.creatable_models = ["AdminPolicy", "Collection"]
      controller.current_ability.can(:create, [AdminPolicy, Collection])
    end

    describe "#new" do
      it "should render the new template" do
        get :new, :model => 'collection'
        response.should render_template(:new)
      end
    end

    describe "#create" do
      before { DulHydra.creatable_models = ["AdminPolicy", "Collection"] }
      after { assigns(:object).delete }
      it "should create a new object" do
        post :create, model: 'collection', object: {title: 'New Collection'}
        assigns(:object).should be_persisted
      end
      it "should grant edit rights to the object creator (user)" do
        post :create, model: 'collection', object: {title: 'New Collection'}
        assigns(:object).edit_users.should include(user.user_key)
      end
      context "governable objects" do
        let(:apo) { AdminPolicy.create }
        after { apo.delete }
        it "should assign an admin policy" do
          post :create, model: 'collection', object: {title: 'New Collection', admin_policy_id: apo.pid}
          assigns(:object).admin_policy_id.should == apo.pid
        end
      end
      context "after creation" do
        context "model is AdminPolicy" do
          it "should redirect to edit default permissions page" do
            post :create, model: 'admin_policy', object: {title: 'New Admin Policy'}
            response.should redirect_to(default_permissions_edit_path(assigns(:object)))
          end
        end
        context "other models" do
          it "should redirect to the object show page" do
            post :create, model: 'collection', object: {title: 'New Collection'}
            response.should redirect_to(object_path(assigns(:object)))
          end
        end
      end
    end
  end

  describe "read and update actions" do
    let(:object) { FactoryGirl.create(:test_model) }
    after { object.delete }

    describe "#show" do
      before do
        object.read_users = [user.user_key]
        object.save
      end
      it "should render the show template" do
        get :show, :id => object
        response.should render_template(:show)
      end
    end

    describe "#edit" do
      before do
        object.edit_users = [user.user_key]
        object.save
      end
      it "should render the hydra-editor edit template" do
        get :edit, :id => object
        response.should render_template('records/edit')
      end
    end

    describe "#update" do
      before do
        object.edit_users = [user.user_key]
        object.save
        controller.stub(:current_object).and_return(object)
      end
      it "should redirect to the show page" do
        put :update, :id => object, :test_model => {:title => "Updated"}
        response.should redirect_to(record_path(object))
      end
      it "should update the object" do
        put :update, :id => object, :test_model => {:title => "Updated"}
        object.reload
        object.title.should == ["Updated"]
      end
    end
  end
end
