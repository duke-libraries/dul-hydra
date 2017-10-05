RSpec.describe TargetsController, type: :controller, targets: true do

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  it_behaves_like "a content object controller" do
    let(:object) { Target.create }
  end

  describe "#show" do
    let(:obj) { FactoryGirl.create(:target) }
    context "when the user can read the object" do
      before do
        obj.roles.grant type: "Viewer", agent: user
        obj.save!
      end
      it "is authorized" do
        get :show, id: obj
        expect(response.response_code).to eq(200)
      end
    end
    context "when the user cannot read the object" do
      it "is unauthorized" do
        get :show, id: obj
        expect(response.response_code).to eq(403)
      end
    end
  end

end
