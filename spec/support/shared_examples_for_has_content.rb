require 'spec_helper'

shared_examples "an object that can have content" do
  let(:object) do
    described_class.new(title: "I Have Content!")
    # obj = described_class.new(title: "I Have Content!")
    # obj.save(validate: false)
    # obj
  end
  after { ActiveFedora::Base.destroy_all }
  context "before new content is saved" do
    context "when the content is a file" do
      it "should run a virus scan"
      context "and a virus is found" do
        it "should not save the object"
      end
    end
    context "when the content is not a file" do
      it "should not run a virus scan"
    end
  end
  context "after content is uploaded" do
    before do
      object.upload fixture_file_upload("library-devil.tiff", "image/tiff")
    end
    it "should have content" do
      expect(object).to have_content
    end
    context "after saving the object" do
      before { object.save(validate: false) }
      it "should have an original_filename" do
        expect(object.original_filename).to eq("library-devil.tiff")
      end
      it "should have a content_type" do
        expect(object.content_type).to eq("image/tiff")
      end
      it "should have a thumbnail (if it's an appropriate type)" do
        expect(object.thumbnail).to be_present
      end
    end # after saving
  end
  context "after content is uploaded with a checksum" do
    context "and the checksum matches" do
      before do
        object.upload fixture_file_upload("library-devil.tiff", "image/tiff"), checksum: "dea56f15b309e47b74fa24797f85245dda0ca3d274644a96804438bbd659555a"      
        object.save(validate: false)
      end
      it "should have content" do
        expect(object).to have_content
      end
    end
    context "and the checksum doesn't match" do
      it "should raise an exception" do
        expect { object.upload fixture_file_upload("library-devil.tiff", "image/tiff"), checksum: "dea56f15b309e47b74fa24797f85245dda0ca3d274644a96804438bbd659555b" }.to raise_error(DulHydra::ChecksumInvalid)
        expect { object.upload! fixture_file_upload("library-devil.tiff", "image/tiff"), checksum: "dea56f15b309e47b74fa24797f85245dda0ca3d274644a96804438bbd659555b" }.to raise_error(DulHydra::ChecksumInvalid)
      end
    end
  end
  context "before content is uploaded" do
    it "should not have content" do
      expect(object).not_to have_content
    end
  end
end
