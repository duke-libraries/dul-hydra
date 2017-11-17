RSpec.describe ExportFilesController, type: :controller do

  let(:user) { FactoryGirl.create(:user) }
  let(:component) { FactoryGirl.build(:component) }

  before do
    component.roles.grant type: "Viewer", agent: "public"
    component.save!
    sign_in user
  end

  describe "success" do
    specify {
      post :create, identifiers: component.pid, basename: "foo", confirmed: true
      expect(response).to be_success
    }
  end

end
