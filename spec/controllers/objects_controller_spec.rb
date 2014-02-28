require 'spec_helper'

describe ObjectsController, objects: true do

  let(:object) { FactoryGirl.create(:test_model) }
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  after do
    user.destroy
    object.destroy
  end
  describe "#show", descriptive_metadata: true do
    before do
      object.read_users = [user.user_key]
      object.save!
    end
    it "should render the show template" do
      get :show, :id => object
      expect(response).to render_template(:show)
    end
  end
  describe "#edit", descriptive_metadata: true do
    before { controller.current_ability.can(:edit, object) }
    it "should render the hydra-editor edit template" do
      get :edit, :id => object
      expect(response).to render_template('records/edit')
    end

    describe "#update", descriptive_metadata: true do
      context "user can edit" do
        before do
          object.edit_users = [user.user_key]
          object.save!
          put :update, :id => object, :object => {:title => ["Updated"]}
        end
        it "should redirect to the descriptive metadata tab of the show page" do
          response.should redirect_to(record_path(object))
        end
        it "should update the object" do
          object.reload
          object.title.should == ["Updated"]
        end
        it "should create an event log entry for the update action" do
          object.event_logs.count.should == 1
        end
      end
      context "user cannot edit" do
        subject { put :update, :id => object, :object => {:title => ["Updated"]} }
        before { controller.current_ability.cannot(:edit, object) }
        its(:response_code) { should == 403 }
      end
      it "should update the object" do
        expect(object.reload.title).to eq(["Updated"])
      end
      it "should create an event log entry for the update action" do
        expect(object.event_logs.count).to eq(1)
      end
    end
  end

end
