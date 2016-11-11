require 'spec_helper'

RSpec.describe SimpleIngestJob, type: :job do

  let(:user_key) { 'joe@test.edu' }
  let(:user_email) { 'joe.test@test.edu' }
  let(:folder_path) { '/foo/bar/baz' }
  let(:filesystem) { Filesystem.new }
  let(:inspection_results) { InspectSimpleIngest::Results.new(filesystem: filesystem) }
  let(:job_params) { { "admin_set" => nil, "batch_user" => user_key, "collection_id" => nil, "config_file" => nil, "folder_path" => folder_path } }

  before do
    allow(User).to receive(:find_by_user_key).with(user_key) { double(email: user_email) }
    allow_any_instance_of(InspectSimpleIngest).to receive(:inspect_filesystem) { inspection_results }
    allow_any_instance_of(SimpleIngest).to receive(:filesystem) { filesystem }
    allow_any_instance_of(SimpleIngest).to receive(:build_batch) { nil }
  end

  describe "success" do
    let(:expected_msg) { "Simple Ingest processing for folder #{folder_path} has completed." }
    it "should generate an appropriate email" do
      expect(JobMailer).to receive(:basic).with(to: user_email,
                                                subject: "COMPLETED - Simple Ingest Job - #{folder_path}",
                                                message: expected_msg).and_call_original
      described_class.perform(job_params)
    end
    it "should send an email" do
      expect { described_class.perform(job_params) }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

end
