RSpec.describe DownloadsController, type: :controller do

  let(:user) { FactoryGirl.create(:user) }

  before {
    @obj = FactoryGirl.create(:component)
    sign_in user
    controller.current_ability.can(:download, ActiveFedora::File)
  }

  describe "file does not exist" do
    it "returns a 404" do
      get :show, id: @obj, file: "foo"
      expect(response.response_code).to eq(404)
    end
  end

  describe "file exists (has content)" do
    it "is successful" do
      get :show, id: @obj, file: "content"
      expect(response.response_code).to eq(200)
    end
  end

  describe "default ('content')" do
    it "is successful" do
      get :show, id: @obj
      expect(response.response_code).to eq(200)
    end
  end
end
