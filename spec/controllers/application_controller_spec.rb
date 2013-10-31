require 'spec_helper'

describe ApplicationController do

  controller do
    def index
      render :text => 'Yay!'
    end

    def remote_user_name=(user_name)
      request.env[DeviseRemoteUser.env_key] = user_name
    end

    def remote_user_email=(email)
      request.env[DeviseRemoteUser.attribute_map[:email]] = email
    end
  end

  describe "#login_remote_user" do
    context "login existing user" do
      let(:user) { FactoryGirl.create(:user) }
      before { controller.remote_user_name = user.username }
      after { user.delete }
      it "should login the remote user" do
        get :index
        controller.user_signed_in?.should be_true
        controller.current_user.should eq(user)
      end
      it "should update the user's attributes" do
        controller.remote_user_email = "scrabble@games.example.com"
        user.email.should_not == "scrabble@games.example.com"
        get :index
        user.reload
        user.email.should == "scrabble@games.example.com"
      end
    end
    context "remote user not present" do
      it "should do nothing" do
        controller.remote_user_name = nil
        get :index
        controller.user_signed_in?.should be_false
      end
    end
    context "create and login new user" do
      let(:username) { "foo" }
      let(:email) { "foo@bar.com" }
      context "autocreation enabled" do
        before do
          DeviseRemoteUser.auto_create = true
          DeviseRemoteUser.attribute_map = {:email => 'mail'}
        end
        after { @user.delete }
        it "should create a user for the remote user, if one doesn't exist" do
          User.find_by_username(username).should be_nil
          controller.remote_user_name = username
          controller.remote_user_email = email
          get :index
          response.should be_successful
          controller.user_signed_in?.should be_true
          @user = User.find_by_username(username)
          @user.should_not be_nil
          controller.current_user.should eq(@user)
        end
      end
      context "autocreation disabled" do
        before { DeviseRemoteUser.auto_create = false }
        it "should not create a user for the remote use" do
          User.find_by_username(username).should be_nil
          controller.remote_user_name = username
          controller.remote_user_email = email
          get :index
          response.should_not be_successful
          controller.user_signed_in?.should be_false
          User.find_by_username(username).should be_nil
        end
      end
    end
    context "don't clobber existing user session" do
      let(:local_user) { FactoryGirl.create(:user) }
      let(:remote_user) { FactoryGirl.create(:user) }
      before { sign_in local_user }
      after do
        local_user.delete
        remote_user.delete
      end
      it "should respect the existing user session" do
        controller.remote_user_name = remote_user.username
        get :index
        controller.current_user.should eq(local_user)
        controller.current_user.should_not eq(remote_user)
      end
    end
  end

end
