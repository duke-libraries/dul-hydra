RSpec.describe BatchObjectsController, type: :controller do

  describe "#show" do
    let(:batch) { FactoryGirl.create(:batch_with_basic_update_batch_object) }
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user }
    specify {
      get :show, id: batch.batch_objects.first
      expect(response.response_code).to eq(200)
    }
  end

end
