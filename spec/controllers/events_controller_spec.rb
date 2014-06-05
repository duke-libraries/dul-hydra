require 'spec_helper'

describe EventsController, events: true do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
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
