require 'spec_helper'

RSpec.describe NestedFolderIngestsController, type: :controller do

  describe "#create" do
    let(:user) { FactoryGirl.create(:user) }
    let(:basepath) { '/foo/bar/' }
    let(:subpath) { 'baz/' }
    let(:folder_path) { File.join(basepath, subpath) }
    let(:checksum_file) { 'my_checksums.txt' }
    let(:metadata_file) { 'my_metadata.txt' }
    let(:test_config_file) do
      Rails.root.join('spec', 'fixtures', 'batch_ingest', 'nested_folder_ingest', 'nested_folder_ingest.yml')
    end
    let(:test_configuration) { YAML.load(File.read(test_config_file)) }
    let(:checksums_location) { test_configuration[:checksums][:location] }
    let(:metadata_location) { test_configuration[:metadata][:location] }
    let(:checksum_path) { File.join(checksums_location, checksum_file) }
    let(:metadata_path) { File.join(metadata_location, metadata_file) }
    let(:job_params) { { "admin_set" => "foo", "basepath" => basepath, "batch_user" => user.user_key,
                         "checksum_file" => checksum_file, "collection_id" => "", "collection_title" => "Test",
                         "config_file" => test_config_file.to_s, "metadata_file" => metadata_file, "subpath" => subpath } }

    before do
      sign_in user
      allow(Dir).to receive(:exist?).and_call_original
      allow(Dir).to receive(:exist?).with(folder_path) { true }
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(checksum_path) { true }
      allow(File).to receive(:exist?).with(metadata_path) { true }
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with(NestedFolderIngest::DEFAULT_CONFIG_FILE.to_s) { File.read(test_config_file) }
      allow_any_instance_of(NestedFolderIngest).to receive(:metadata_path) { metadata_path }
      allow_any_instance_of(IngestMetadata).to receive(:validate_headers) { [] }
      allow_any_instance_of(IngestMetadata).to receive(:locators) { [] }
    end

    describe "when the user can create NestedFolderIngest" do
      before {
        controller.current_ability.can(:create, NestedFolderIngest)
        allow_any_instance_of(NestedFolderIngest).to receive(:inspection_results) { nil }
      }
      it "enqueues the job and renders the 'queued' view" do
        expect(Resque).to receive(:enqueue).with(NestedFolderIngestJob, job_params)
        post :create, nested_folder_ingest: { "basepath" => basepath, "subpath" => subpath,
                                              "checksum_file" => checksum_file, "collection_id" => "",
                                              "collection_title" => "Test", "config_file" => test_config_file.to_s,
                                              "admin_set" => "foo", "metadata_file" => metadata_file }
        expect(response).to render_template(:queued)
      end
      describe "and the collection is specified" do
        describe "and the user can add children to the collection" do
          before {
            controller.current_ability.can(:add_children, "test:1")
          }
          it "is successful" do
            post :create, nested_folder_ingest: { "basepath" => basepath, "subpath" => subpath, "checksum_file" => checksum_file, "collection_id" => "test:1" }
            expect(response.response_code).to eq(200)
          end
        end
      end
      describe "and the user cannot add children to the collection" do
        before {
          controller.current_ability.cannot(:add_children, "test:1")
        }
        it "is forbidden" do
          post :create, nested_folder_ingest: { "basepath" => basepath, "subpath" => subpath, "checksum_file" => checksum_file, "collection_id" => "test:1" }
          expect(response.response_code).to eq(403)
        end
      end
    end

    describe "when the user cannot create NestedFolderIngest" do
      before {
        controller.current_ability.cannot(:create, NestedFolderIngest)
      }
      describe "and the collection is not specified" do
        it "is forbidden" do
          post :create, nested_folder_ingest: { "basepath" => basepath, "subpath" => subpath, "checksum_file" => checksum_file, "collection_id" => "" }
          expect(response.response_code).to eq(403)
        end
      end
      describe "and the collection is specified" do
        describe "and the user can add children to the collection" do
          before {
            controller.current_ability.can(:add_children, "test:1")
          }
          it "is successful" do
            post :create, nested_folder_ingest: { "basepath" => basepath, "subpath" => subpath, "checksum_file" => checksum_file, "collection_id" => "test:1" }
            expect(response.response_code).to eq(200)
          end
        end
      end
      describe "and the user cannot add children to the collection" do
        before {
          controller.current_ability.cannot(:add_children, "test:1")
        }
        it "is forbidden" do
          post :create, nested_folder_ingest: { "basepath" => basepath, "subpath" => subpath, "checksum_file" => checksum_file, "collection_id" => "test:1" }
          expect(response.response_code).to eq(403)
        end
      end
    end
  end
end
