require 'spec_helper'

RSpec.describe SimpleIngestJob, type: :job do

  let(:user_key) { 'joe@test.edu' }
  let(:user_email) { 'joe.test@test.edu' }
  let(:folder_path) { '/foo/bar/baz' }
  let(:job_params) { { "admin_set" => nil, "batch_user" => user_key, "collection_id" => nil, "config_file" => nil, "folder_path" => folder_path } }

  before do
    allow(User).to receive(:find_by_user_key).with(user_key) { double(email: user_email) }
  end

  describe "success" do
    let(:expected_msg) { "Simple Ingest processing for folder #{folder_path} has completed." }
    it "should generate an email" do
      expect(JobMailer).to receive(:basic).with(to: user_email,
                                                subject: "COMPLETED - Simple Ingest Job - #{folder_path}",
                                                message: expected_msg)
      described_class.perform(job_params)
    end
  end

  # describe "failure" do
  #   let(:expected_msg) { "Simple Ingest processing for folder #{folder_path} FAILED." }
  #   before do
  #     # allow(SimpleIngest).to receive(:new).and_raise(RuntimeError)
  #     allow(described_class).to receive(:perform).with(job_params).and_raise(RuntimeError)
  #   end
  #   it "should generate an email" do
  #     expect(JobMailer).to receive(:basic).with(to: user_email,
  #                                               subject: "FAILED - Simple Ingest Job - #{folder_path}",
  #                                               message: expected_msg)
  #     described_class.perform(job_params)
  #   end
  # end
end
