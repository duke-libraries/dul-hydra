def upload_content
  patch :upload, id: object, content: { file: file }
end

shared_examples "a content object controller" do

  describe "#upload" do
    let(:file) { fixture_file_upload('imageA.jpg') }
    context "when the user can upload content" do
      before { controller.current_ability.can(:upload, object_class) }
      it "should not throw an error" do
        expect { upload_content }.not_to raise_error
      end
    end
    context "when the user cannot upload content" do
      before { controller.current_ability.cannot(:upload, object_class) }
      it "should be unauthorized" do
        upload_content
        expect(response.response_code).to eq(403)
      end
    end
  end

end

