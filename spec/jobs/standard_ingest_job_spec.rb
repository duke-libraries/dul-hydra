require 'spec_helper'

RSpec.describe StandardIngestJob, type: :job do

  let(:user_key) { 'joe@test.edu' }
  let(:basepath) { "/foo/bar/" }
  let(:subpath) { "baz" }
  let(:collection_pid) { 'test:1' }
  let(:batch) { double('Ddr::Batch::Batch', id: 5) }
  let(:item_count) { 7 }
  let(:component_count) { 10 }
  let(:target_count) { 2 }
  let(:job_params) { { "batch_user" => user_key, "basepath" => basepath, "subpath" => subpath } }

  before do
    allow_any_instance_of(StandardIngest).to receive(:load_configuration) { {} }
    allow_any_instance_of(InspectStandardIngest).to receive(:call) { inspection_results }
  end

  it_behaves_like "an abstract job"

  describe "finished" do
    describe "success" do
      let(:file_count) { 13 }
      let(:model_stats) { { collections: collection_count, items: item_count,
                            components: component_count, targets: target_count } }
      let(:inspection_results) do
        InspectStandardIngest::Results.new(file_count, [ 'metadata.txt' ], model_stats, Filesystem.new)
      end
      before do
        allow_any_instance_of(StandardIngest).to receive(:build_batch) { batch }
      end
      describe "collection ID present" do
        let(:collection_count) { 0 }
        before { job_params.merge!({ "collection_id" => collection_pid }) }
        it "should publish the appropriate notification" do
          expect(ActiveSupport::Notifications).to receive(:instrument).with(StandardIngest::FINISHED,
                                                                            user_key: user_key,
                                                                            basepath: basepath,
                                                                            subpath: subpath,
                                                                            collection_id: collection_pid,
                                                                            file_count: file_count,
                                                                            model_stats: model_stats,
                                                                            errors: [],
                                                                            batch_id: batch.id)
          described_class.perform(job_params)
        end
      end
      describe "collection ID not present" do
        let(:collection_count) { 1 }
        it "should publish the appropriate notification" do
          expect(ActiveSupport::Notifications).to receive(:instrument).with(StandardIngest::FINISHED,
                                                                            user_key: user_key,
                                                                            basepath: basepath,
                                                                            subpath: subpath,
                                                                            collection_id: nil,
                                                                            file_count: file_count,
                                                                            model_stats: model_stats,
                                                                            errors: [],
                                                                            batch_id: batch.id)
          described_class.perform(job_params)
        end
      end
    end
    describe "errors" do
      let(:error_message) { 'Error' }
      let(:error) { DulHydra::BatchError.new(error_message) }
      let(:inspection_results) do
        InspectStandardIngest::Results.new
      end
      before do
        allow_any_instance_of(StandardIngest).to receive(:build_batch) { raise error }
      end
      describe "collection ID present" do
        before { job_params.merge!({ "collection_id" => collection_pid }) }
        it "should publish the appropriate notification" do
          expect(ActiveSupport::Notifications).to receive(:instrument).with(StandardIngest::FINISHED,
                                                                            user_key: user_key,
                                                                            basepath: basepath,
                                                                            subpath: subpath,
                                                                            collection_id: collection_pid,
                                                                            file_count: nil,
                                                                            model_stats: nil,
                                                                            errors: [ error_message ],
                                                                            batch_id: nil)
          described_class.perform(job_params)
        end
      end
      describe "collection ID not present" do
        it "should publish the appropriate notification" do
          expect(ActiveSupport::Notifications).to receive(:instrument).with(StandardIngest::FINISHED,
                                                                            user_key: user_key,
                                                                            basepath: basepath,
                                                                            subpath: subpath,
                                                                            collection_id: nil,
                                                                            file_count: nil,
                                                                            model_stats: nil,
                                                                            errors: [ error_message ],
                                                                            batch_id: nil)
          described_class.perform(job_params)
        end
      end
    end
  end

end
