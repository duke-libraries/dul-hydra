require 'spec_helper'

describe ApplicationController do

  controller do
    def index
      render :text => 'Yay!'
    end

    def remote_user_name=(user_name)
      request.env['REMOTE_USER'] = user_name
    end
  end

  describe "#login_remote_user" do
    context "login existing user" do
      let(:user) { FactoryGirl.create(:user) }
      after { user.delete }
      it "should login the remote user" do
        controller.remote_user_name = user.email
        get :index
        controller.user_signed_in?.should be_true
        controller.current_user.should eq(user)
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
      let(:email) { "foo@bar.com" }
      after { @user.delete }
      it "should create a user for the remote user, if one doesn't exist" do
        User.find_by_email(email).should be_nil
        controller.remote_user_name = email
        get :index
        controller.user_signed_in?.should be_true
        @user = User.find_by_email(email)
        @user.should_not be_nil
        controller.current_user.should eq(@user)
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
        controller.remote_user_name = remote_user.email
        get :index
        controller.current_user.should eq(local_user)
        controller.current_user.should_not eq(remote_user)
      end
    end
  end

end
