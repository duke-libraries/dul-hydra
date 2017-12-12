require 'spec_helper'

RSpec.describe MonitorDatastreamUpload, type: :service do

  let(:user_key) { 'joe@test.edu' }
  let(:user_email) { 'joe.test@test.edu' }
  let(:basepath) { '/foo/bar/' }
  let(:subpath) { 'baz/' }
  let(:folder_path) { File.join(basepath, subpath) }
  let(:job_params) { { "batch_user" => user_key, "folder_path" => folder_path } }
  let(:collection_title) { 'Test Collection' }
  let(:collection_pid) { 'test:1' }
  let(:collection) { double('Collection', pid: collection_pid, title: [ collection_title ]) }
  let(:notification) { [ DatastreamUpload::FINISHED, Time.now, Time.now, 'abcdef', payload ] }
  let(:payload) { { user_key: user_key, basepath: basepath, collection_id: collection_pid, subpath: subpath } }

  before do
    allow(User).to receive(:find_by_user_key).with(user_key) { double('User', email: user_email) }
  end

  describe 'success' do
    let(:batch) { double('Ddr::Batch::Batch', id: 5) }
    let(:batch_url) { Rails.application.routes.url_helpers.batch_url(batch, host: DulHydra.host_name, protocol: 'https') }
    let(:file_count) { 7 }
    let(:expected_msg) do <<~EOS
        Datastream Upload has created batch ##{batch.id}
        For collection: #{collection_title}
        From folder: #{folder_path}
        Files found: #{file_count}

        To review and process the batch, go to #{batch_url}
      EOS
    end
    before do
      payload.merge!({ errors: [], batch_id: batch.id, file_count: file_count })
      allow(Ddr::Batch::Batch).to receive(:find).with(batch.id) { batch }
      allow(Collection).to receive(:find).with(collection_pid) { collection }
      allow(batch).to receive_message_chain(:batch_objects, :where) { [ collection_batch_object ] }
    end
      it "should generate an appropriate email" do
        expect(JobMailer).to receive(:basic).with(to: user_email,
                                                  subject: "BATCH CREATED - Datastream Upload Job - #{collection_title}",
                                                  message: expected_msg).and_call_original
        described_class.call(*notification)
      end
      it "should send an email" do
        expect { described_class.call(*notification) }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
  end

  describe 'errors' do
    let(:error_message) { 'Error' }
    let(:expected_msg) do <<~EOS
        ERRORS in Datastream Upload
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
      it "should generate an appropriate email" do
        expect(JobMailer).to receive(:basic).with(to: user_email,
                                                  subject: "ERRORS - Datastream Upload Job - #{collection_title}",
                                                  message: expected_msg).and_call_original
        described_class.call(*notification)
      end
      it "should send an email" do
        expect { described_class.call(*notification) }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
  end
end
