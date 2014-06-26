require 'spec_helper'

describe EventsController, events: true do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "index" do
    let!(:event) { Event.create(pid: object.pid) }
    let(:object) { FactoryGirl.create(:test_model) }
    context "event is associated with user" do
      before do
        event.user = user
        event.save!
      end
      it "should include the event" do
        get :index, pid: object.pid
        expect(assigns(:events)).to include(event)
      end
    end
    context "event is associated with object to which user has read access" do
      before do
        object.read_users = [user.user_key]
        object.save!
      end
      it "should include the event" do
        get :index, pid: object.pid
        expect(assigns(:events)).to include(event)
      end
    end
    context "event is not associated with user nor object to which user has read access" do
      it "should not include the event" do
        get :index, pid: object.pid
        expect(assigns(:events)).to_not include(event)
      end
    end
  end

  describe "show" do
    let(:event) { Event.create(pid: object.pid) }
    let(:object) { FactoryGirl.create(:test_model) }
    before { controller.current_ability.can(:read, event) }
    it "should render the event" do
      get :show, id: event
      expect(response).to be_successful
      expect(response).to render_template :show
    end
  end

end
