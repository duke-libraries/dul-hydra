require 'spec_helper'

RSpec.describe MonitorStandardIngest, type: :service do

  let(:user_key) { 'joe@test.edu' }
  let(:user_email) { 'joe.test@test.edu' }
  let(:folder_path) { '/foo/bar/baz' }
  let(:job_params) { { "batch_user" => user_key, "folder_path" => folder_path } }
  let(:collection_batch_object) { double('Ddr::Batch::BatchObject', model: 'Collection', pid: collection_pid) }
  let(:collection_title) { 'Test Collection' }
  let(:collection_title_attribute) { Ddr::Batch::BatchObjectAttribute.new(name: 'title', value: collection_title) }
  let(:collection_pid) { 'test:1' }
  let(:collection) { double('Collection', pid: collection_pid, title: [ collection_title ]) }
  let(:notification) { [ StandardIngest::FINISHED, Time.now, Time.now, 'abcdef', payload ] }
  let(:payload) { { user_key: user_key,
                    folder_path: folder_path } }

  before do
    allow(User).to receive(:find_by_user_key).with(user_key) { double('User', email: user_email) }
  end

  describe 'success' do
    let(:batch) { double('Ddr::Batch::Batch', id: 5) }
    let(:batch_url) { Rails.application.routes.url_helpers.batch_url(batch, host: DulHydra.host_name, protocol: 'https') }
    let(:item_count) { 7 }
    let(:component_count) { 10 }
    let(:target_count) { 2 }
    let(:file_count) { 13 }
    let(:model_stats) { { collections: collection_count, items: item_count,
                          components: component_count, targets: target_count } }
    let(:expected_msg) do <<~EOS
        Standard Ingest has created batch ##{batch.id}
        For collection: #{collection_title}
        From folder: #{folder_path}
        Files found: #{file_count}
        Object model stats
          Collection: #{collection_count}
                Item: #{item_count}
           Component: #{component_count}
              Target: #{target_count}

        To review and process the batch, go to #{batch_url}
      EOS
    end
    before do
      payload.merge!({ errors: [], batch_id: batch.id, file_count: file_count, model_stats: model_stats })
      allow(Ddr::Batch::Batch).to receive(:find).with(batch.id) { batch }
      allow(Collection).to receive(:find).with(collection_pid) { collection }
      allow(batch).to receive_message_chain(:batch_objects, :where) { [ collection_batch_object ] }
    end
    describe 'collection ID present' do
      let(:collection_count) { 0 }
      before do
        payload.merge!({ collection_id: collection_pid })
      end
      it "should generate an appropriate email" do
        expect(JobMailer).to receive(:basic).with(to: user_email,
                                                  subject: "COMPLETED - Standard Ingest Job - #{collection_title}",
                                                  message: expected_msg).and_call_original
        described_class.call(*notification)
      end
      it "should send an email" do
        expect { described_class.call(*notification) }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
    describe "collection ID not present" do
      let(:collection_count) { 1 }
      describe "collection title attribute present" do
        before do
          allow(collection_batch_object)
              .to receive_message_chain(:batch_object_attributes, :where) { [ collection_title_attribute ] }
        end
        it "should generate an appropriate email" do
          expect(JobMailer).to receive(:basic).with(to: user_email,
                                                    subject: "COMPLETED - Standard Ingest Job - #{collection_title}",
                                                    message: expected_msg).and_call_original
          described_class.call(*notification)
        end
        it "should send an email" do
          expect { described_class.call(*notification) }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end
      describe "collection title attribute not present" do
        let(:collection_title) { nil }
        before do
          allow(collection_batch_object)
              .to receive_message_chain(:batch_object_attributes, :where) { [ ] }
        end
        it "should generate an appropriate email" do
          expect(JobMailer).to receive(:basic).with(to: user_email,
                                                    subject: "COMPLETED - Standard Ingest Job - #{collection_title}",
                                                    message: expected_msg).and_call_original
          described_class.call(*notification)
        end
        it "should send an email" do
          expect { described_class.call(*notification) }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end
    end
  end

  describe 'errors' do
    let(:error_message) { 'Error' }
    let(:expected_msg) do <<~EOS
        ERRORS in Standard Ingest
        For collection: #{collection_title}
        From folder: #{folder_path}
        
        ERRORS:
        - #{error_message}
      EOS
    end
    before do
      payload.merge!({ errors: [ error_message ] })
      allow(Collection).to receive(:find).with(collection_pid) { collection }
    end
    describe 'collection ID present' do
      before do
        payload.merge!({ collection_id: collection_pid })
      end
      it "should generate an appropriate email" do
        expect(JobMailer).to receive(:basic).with(to: user_email,
                                                  subject: "ERRORS - Standard Ingest Job - #{collection_title}",
                                                  message: expected_msg).and_call_original
        described_class.call(*notification)
      end
      it "should send an email" do
        expect { described_class.call(*notification) }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
    describe "collection ID not present" do
      let(:collection_title) { nil }
      it "should generate an appropriate email" do
        expect(JobMailer).to receive(:basic).with(to: user_email,
                                                  subject: "ERRORS - Standard Ingest Job - ",
                                                  message: expected_msg).and_call_original
        described_class.call(*notification)
      end
      it "should send an email" do
        expect { described_class.call(*notification) }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end
end
