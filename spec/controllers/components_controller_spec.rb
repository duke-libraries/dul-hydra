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
    it "should deny access to an anonymous user"
    context "authenticated user" do
      before do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end
      after do
        sign_out @user
        @user.delete
      end
      it "should have a successful response" do
        response.should be_successful
      end
      it "should create a new component"
    end
  end
  context "#create" do
    subject { post :create, :component => {title: "Test Component", identifier: "foobar123"} }
    it "should deny access to an anonymous user"
    context "authenticated user" do
      before do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end
      after do
        sign_out @user
        @user.delete
      end
      it "persists the new component" # errors v. no errors?
      it "redirects to the show action" do
        expect(subject).to redirect_to(:action => :show, 
                                       :id => assigns(:component).id)
      end
    end
  end
  context "#show" do
    subject { get :show, :id => @component }
    before do
      @component = Component.create
    end
    after do
      @component.delete
    end
    context "publicly readable component" do
      before do
        @component.read_groups = ["public"]
        @component.save!
      end
      it "should have a sucessful response" do
        response.should be_successful
      end
    end
    context "restricted read component" do
      before do
        @component.read_groups = ["registered"]
        @component.save!
      end
      context "anonymous user" do
        it "should have a forbidden response" do
          pending "further investigation"
          puts @component.pid
          puts @component.permissions
          response.response_code.should eq(403)
        end
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
        it "should have a success response" do
          response.should be_successful
        end
      end
    end
  end
  context "#edit" do
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
      it "should have a forbidden response" do
        get :edit, :id => @component
        response.response_code.should eq(403)
      end
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
      it "should have a forbidden response" do
        get :edit, :id => @component
        response.response_code.should eq(403)
      end
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
      it "should have a success response" do
        get :edit, :id => @component
        response.should be_successful
      end
    end
  end
  context "#update" do    
  end
  context "#destroy" do
  end
end
