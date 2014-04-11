require 'spec_helper'
require 'support/shared_examples_for_repository_controllers'

describe TargetsController, targets: true do

  let(:user) { FactoryGirl.create(:user) }

  before { sign_in user }

  after do
    User.destroy_all
    ActiveFedora::Base.destroy_all
  end

  describe "#show" do
    let(:object) { FactoryGirl.create(:target) }
    context "when the user can read the object" do
      before { controller.current_ability.can(:read, object) }
      it "should render the show template" do
        expect(get :show, id: object).to render_template(:show)
      end
    end
    context "when the user cannot read the object" do
      before { controller.current_ability.cannot(:read, object) }
      it "should be unauthorized" do
        get :show, id: object
        expect(response.response_code).to eq(403)
      end
    end
  end

end
