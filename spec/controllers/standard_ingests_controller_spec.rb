require 'spec_helper'

RSpec.describe StandardIngestsController, type: :controller do

  describe "#create" do
    let(:user) { FactoryGirl.create(:user) }
    let(:folder_path) { "/foo/bar/baz" }
    let(:checksum_path) { File.join(folder_path, StandardIngest::CHECKSUM_FILE).to_s }
    let(:data_path) { File.join(folder_path, StandardIngest::DATA_DIRECTORY).to_s }
    let(:metadata_path) { File.join(data_path, StandardIngest::METADATA_FILE).to_s }
    let(:job_params) { {"admin_set" => nil, "batch_user" => user.user_key, "collection_id" => "",
                        "config_file" => StandardIngest::DEFAULT_CONFIG_FILE.to_s, "folder_path" => folder_path } }

    before do
      sign_in user
      allow(Dir).to receive(:exist?).and_call_original
      allow(Dir).to receive(:exist?).with(folder_path) { true }
      allow(Dir).to receive(:exist?).with(data_path) { true }
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(checksum_path) { true }
      allow(File).to receive(:exist?).with(metadata_path) { true }
      allow_any_instance_of(StandardIngest).to receive(:validate_metadata_file) { nil }
    end

    describe "when the user can create StandardIngest" do
      before {
        controller.current_ability.can(:create, StandardIngest)
      }
      it "enqueues the job and renders the 'queued' view" do
        expect(Resque).to receive(:enqueue).with(StandardIngestJob, job_params)
        post :create, standard_ingest: {"folder_path" => folder_path, "collection_id" => "" }
        expect(response).to render_template(:queued)
      end
      describe "and the collection is specified" do
        describe "and the user can add children to the collection" do
          before {
            controller.current_ability.can(:add_children, "test:1")
          }
          it "is successful" do
            post :create, standard_ingest: {"folder_path" => folder_path, "collection_id" => "test:1" }
            expect(response.response_code).to eq(200)
          end
        end
      end
      describe "and the user cannot add children to the collection" do
        before {
          controller.current_ability.cannot(:add_children, "test:1")
        }
        it "is forbidden" do
          post :create, standard_ingest: {"folder_path" => folder_path, "collection_id" => "test:1" }
          expect(response.response_code).to eq(403)
        end
      end
    end

    describe "when the user cannot create StandardIngest" do
      before {
        controller.current_ability.cannot(:create, StandardIngest)
      }
      describe "and the collection is not specified" do
        it "is forbidden" do
          post :create, standard_ingest: {"folder_path" => folder_path, "collection_id" => "" }
          expect(response.response_code).to eq(403)
        end
      end
      describe "and the collection is specified" do
        describe "and the user can add children to the collection" do
          before {
            controller.current_ability.can(:add_children, "test:1")
          }
          it "is successful" do
            post :create, standard_ingest: {"folder_path" => folder_path, "collection_id" => "test:1" }
            expect(response.response_code).to eq(200)
          end
        end
      end
      describe "and the user cannot add children to the collection" do
        before {
          controller.current_ability.cannot(:add_children, "test:1")
        }
        it "is forbidden" do
          post :create, standard_ingest: {"folder_path" => folder_path, "collection_id" => "test:1" }
          expect(response.response_code).to eq(403)
        end
      end
    end
  end
end
