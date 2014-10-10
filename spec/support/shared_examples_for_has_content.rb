require 'spec_helper'
require 'openssl'

shared_examples "an object that can have content" do

  let(:object) { described_class.new(title: [ "I Have Content!" ]) }

  it "should delegate :validate_checksum! to :content" do
    checksum = "dea56f15b309e47b74fa24797f85245dda0ca3d274644a96804438bbd659555a"
    expect(object.content).to receive(:validate_checksum!).with(checksum, "SHA-256")
    object.validate_checksum!(checksum, "SHA-256")
  end

  describe "indexing" do
    let(:file) { fixture_file_upload("library-devil.tiff", "image/tiff") }
    before { object.upload file }
    it "should index the content ds control group" do
      expect(object.to_solr).to include(DulHydra::IndexFields::CONTENT_CONTROL_GROUP)
    end
  end

  describe "adding a file" do
    let(:file) { fixture_file_upload("library-devil.tiff", "image/tiff") }
    context "defaults" do
      before { object.add_file file, "content" }
      it "should have an original_filename" do
        expect(object.original_filename).to eq("library-devil.tiff")
      end
      it "should have a content_type" do
        expect(object.content_type).to eq("image/tiff")
      end
      it "should create a 'virus check' event for the object" do
        expect { object.save }.to change { object.virus_checks.count }.by(1)
      end
    end
    context "with option `:original_name=>false`" do
      before { object.add_file file, "content", original_name: false }
      it "should not have an original_filename" do
        expect(object.original_filename).to be_nil
      end
    end
    context "with `:original_name` option set to a string" do
      before { object.add_file file, "content", original_name: "another-name.tiff" }
      it "should have an original_filename" do
        expect(object.original_filename).to eq("another-name.tiff")
      end
    end
  end

  describe "save" do

    describe "when content is not present" do
      it "should not save" do
        expect(object.save).to be false
        expect(object.errors[:content]).to include "can't be blank"
      end
    end

    describe "when new content is present" do

      context "and it's a new object" do
        before { object.add_file file, "content" }

        context "and the content is an image" do
          let(:file) { fixture_file_upload("library-devil.tiff", "image/tiff") }
          it "should generate a thumbnail" do
            expect(object.thumbnail).not_to be_present
            object.save
            expect(object.thumbnail).to be_present
          end
        end
        context "and the content is a pdf" do
          let(:file) { fixture_file_upload("sample.pdf", "application/pdf") }
          it "should generate a thumbnail" do
            expect(object.thumbnail).not_to be_present
            object.save
            expect(object.thumbnail).to be_present
          end
        end
        context "and the content is neither an image nor a pdf" do
          let(:file) { fixture_file_upload("sample.docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document") }
          it "should not generate a thumbnail" do
            expect(object.thumbnail).not_to be_present
            object.save
            expect(object.thumbnail).not_to be_present
          end
        end
      end

      context "and it's an existing object with content" do
        before { object.upload! fixture_file_upload('library-devil.tiff', 'image/tiff') }

        context "and the content is an image" do
          let(:file) { fixture_file_upload("image1.tiff", "image/tiff") }
          it "should generate a new thumbnail" do
            expect(object.thumbnail).to be_present
            expect { object.upload! file }.to change { object.thumbnail.content }
          end
        end
        context "and the content is a pdf" do
          let(:file) { fixture_file_upload("sample.pdf", "application/pdf") }
          it "should generate a new thumbnail" do
            expect(object.thumbnail).to be_present
            expect { object.upload! file }.to change { object.thumbnail.content }
          end
        end
        context "and the content is neither an image nor a pdf" do
          let(:file) { fixture_file_upload("sample.docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document") }
          it "should delete the thumbnail" do
            expect(object.thumbnail).to be_present
            object.upload! file
            expect(object.thumbnail).to_not be_present
          end
        end
      end
    end
  end

  describe "#upload" do
    let(:file) { fixture_file_upload("library-devil.tiff", "image/tiff") }
    it "should change the content" do
      expect { object.upload file }.to change(object, :content_changed?).from(false).to(true)
    end
    it "should check the file for viruses" do
      expect(DulHydra::Services::Antivirus).to receive(:scan).with(file)
      object.upload file
    end
  end

  describe "#upload!" do 
    let(:file) { fixture_file_upload("library-devil.tiff", "image/tiff") }
    it "should change the content" do
      expect { object.upload! file }.to change { object.content.content }
    end    
    it "should save the object" do
      expect(object).to receive(:save)
      object.upload! file
    end
  end

end
