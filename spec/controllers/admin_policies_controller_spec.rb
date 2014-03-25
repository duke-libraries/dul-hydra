require 'spec_helper'

def create_policy
  post :create, admin_policy: {title: "New Policy", description: "We will control your destiny!"}
end

def update_policy
  patch :default_permissions, id: object, permissions: {"discover" => ["group:public", "user:Sally", "user:Mitch"], "read" => ["group:registered", "user:Gil", "user:Ben"], "edit" => ["group:editors", "group:managers", "user:Rocky", "user:Gwen", "user:Teresa"]}, license: {"title" => "No Access", "description" => "No one can get to it", "url" => "http://www.example.com"}
end

describe AdminPoliciesController do

  let(:user) { FactoryGirl.create(:user) }

  before { sign_in user }

  after do
    User.destroy_all
    ActiveFedora::Base.destroy_all
    EventLog.destroy_all
  end

  it_behaves_like "a repository object controller" do
    let(:create_object) { Proc.new { create_policy } }
    let(:new_object) { Proc.new { get :new } }
  end

  describe "#default_permissions" do
    let(:object) { FactoryGirl.create(:admin_policy) }
    context "GET" do
      context "when the user can edit the object" do
        before { controller.current_ability.can(:edit, object) }
        it "should render the default_permissions template" do
          expect(get :default_permissions, id: object).to render_template("default_permissions")      
        end
      end
      context "when the user cannot edit the object" do
        before { controller.current_ability.cannot(:edit, object) }
        it "should be unauthorized" do
          get :default_permissions, id: object
          expect(response.response_code).to eq(403)
        end
      end
    end
    context "PATCH" do
      context "when the user can edit the object" do
        before { controller.current_ability.can(:edit, object) }
        it "should update the default permissions" do
          update_policy
          object.reload
          object.default_discover_groups.should == ["public"]
          object.default_read_groups.should == ["registered"]
          object.default_edit_groups.should == ["editors", "managers"]
          object.default_discover_users.should == ["Sally", "Mitch"]
          object.default_read_users.should == ["Gil", "Ben"]
          object.default_edit_users.should == ["Rocky", "Gwen", "Teresa"]
          object.default_license_title.should == "No Access"
          object.default_license_description.should == "No one can get to it"
          object.default_license_url.should == "http://www.example.com"
        end
        it "should redirect to the show view" do
          update_policy
          expect(response).to redirect_to(action: "show", tab: "default_permissions")
        end
        it "should create an event log entry for the action" do
          expect{ update_policy }.to change{ object.event_logs(action: EventLog::Actions::MODIFY_POLICY).count }.by(1)
        end
      end
      context "when the user cannot edit the object" do
        before { controller.current_ability.cannot(:edit, object) }
        it "should be unauthorized" do
          update_policy
          expect(response.response_code).to eq(403)
        end
      end
    end
  end
end
