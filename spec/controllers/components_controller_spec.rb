require 'spec_helper'

describe ComponentsController do

  context "#index" do
    subject { get :index }
    it "renders the index template" do
      expect(subject).to render_template(:index)
    end
  end

  context "#new" do
    subject { get :new }
    context "anonymous user" do
      its(:response_code) { should eq(403) }
    end
    context "authenticated user" do
      before do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end
      after do
        sign_out @user
        @user.delete
      end
      it { should be_successful }
      it "should create a new component" do
        get :new # DRY
        assigns(:component).should be_kind_of(Component)
      end
    end
  end

  context "#create" do
    subject { post :create, :component => {title: "Test Component", identifier: "foobar123"} }
    context "anonymous user" do
      its(:response_code) { should eq(403) }
    end
    context "authenticated user" do
      before do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end
      after do
        sign_out @user
        @user.delete
      end
      it "persists the new component" do # errors v. no errors?
        # DRY
        post :create, :component => {title: "Test Component", identifier: "foobar123"}
        Component.find(assigns(:component).id).should be_kind_of(Component)
      end
      it "redirects to the show action" do
        expect(subject).to redirect_to(:action => :show, 
                                       :id => assigns(:component).id)
      end
    end
  end

  context "#show" do
    subject { get :show, :id => @component }
    context "publicly readable component" do
      context "controlled by permissions" do
        before do
          @component = Component.new
          @component.read_groups = ["public"]
          @component.save!
        end
        after do
          @component.delete
        end
        it { should be_successful }
      end
      context "controlled by policy" do
        before do
          @component = Component.new
          @apo = FactoryGirl.create(:public_read_policy)
          @component.admin_policy = @apo
          @component.save!
        end
        after do
          @apo.delete
          @component.delete
        end
        it { should be_successful }
      end
    end
    context "restricted read component" do
      before do
        @component = Component.new
        @component.read_groups = ["registered"]
        @component.save!
      end
      after do
        @component.delete
      end
      context "anonymous user" do
        its(:response_code) { should eq(403) }
      end
      context "authenticated user" do
        before do
          @user = FactoryGirl.create(:user)
          sign_in @user
        end
        after do
          sign_out @user
          @user.delete
        end
        it { should be_successful }
      end
    end
  end

  context "#edit" do
    subject { get :edit, :id => @component }
    before do
      @component = Component.new
      @component.read_groups = ["public"]
      @component.edit_groups = [DulHydra::Permissions::EDITOR_GROUP_NAME]
      @component.save!
    end
    after do
      @component.delete
    end
    context "anonymous user" do
      its(:response_code) { should eq(403) }
    end
    context "authenticated user not having edit permission" do
      before do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end
      after do
        sign_out @user
        @user.delete
      end
      its(:response_code) { should eq(403) }
    end
    context "authenticated user having edit permission" do
      before do
        @user = FactoryGirl.create(:editor)
        sign_in @user
      end
      after do
        sign_out @user
        @user.delete
      end
      it { should be_successful }
    end
  end

  context "#update" do    
    subject { put :update, :id => @component }
  end

  context "#destroy" do
    subject { delete :destroy, :id => @component }
  end

end
