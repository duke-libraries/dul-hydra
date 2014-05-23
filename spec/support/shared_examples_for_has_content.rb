require 'spec_helper'

shared_examples "an object that can have content" do
  let(:object) { described_class.new(title: "I Have Content!") }
  after do
    ActiveFedora::Base.destroy_all
    PreservationEvent.destroy_all
  end
  context "when new content is saved" do
    context "and the content is a file" do
      let(:file) { fixture_file_upload("library-devil.tiff", "image/tiff") }
      before { object.content.content = file }
      it "should run a virus scan" do
        expect(DulHydra::Services::Antivirus).to receive(:scan).with(file).and_call_original
        object.save
      end
      context "and a virus is found" do
        before { allow(DulHydra::Services::Antivirus).to receive(:scan).with(file).and_raise(DulHydra::Services::Antivirus::VirusFoundError) }
        it "should not persist the object" do
          expect { object.save }.to raise_error
          expect(object).to be_new_record
        end
      end
      context "and no virus is found" do
        before { object.save }
        it "should create a 'virus check' preservation event for the object" do
          expect(PreservationEvent.events_for(object, PreservationEvent::VIRUS_CHECK).count).to eq(1)
        end
      end
    end
    context "and the content is not a file" do
      before { object.content.content = "A string" }
      it "should not run a virus scan" do
        expect(DulHydra::Services::Antivirus).not_to receive(:scan)
        object.save!
      end
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
