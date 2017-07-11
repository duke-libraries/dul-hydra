require 'spec_helper'

RSpec.describe BuildBatchObjectFromDatastreamUpload, type: :service, batch: true do

  let(:batch) { Ddr::Batch::Batch.new }
  let(:repo_id) { 'test:1' }
  let(:ds_name) { Ddr::Datastreams::INTERMEDIATE_FILE }
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'imageA.jpg').to_s }
  let(:checksum) { '03f717284d2f8c5ffb0714cb85d1d6689cffa0b0' }
  let(:base_service_args) { { batch: batch, file_path: file_path, datastream_name: ds_name, repo_id: repo_id } }
  let(:checksum_service_args) { { checksum: checksum } }
  let(:service) { BuildBatchObjectFromDatastreamUpload.new(service_args) }

  describe "batch object" do
    let(:service_args) { base_service_args }
    it "creates an UpdateBatchObject for the batch" do
      batch_object = service.call
      expect(batch_object).to be_a(Ddr::Batch::UpdateBatchObject)
      expect(batch_object.batch).to eq(batch)
    end
  end

  describe "batch object datastream" do
    describe "no checksum provided" do
      let(:service_args) { base_service_args }
      it "creates an appropriate batch object datastream for the update batch object" do
        batch_object = service.call
        bods = batch_object.batch_object_datastreams
        expect(bods.size).to eq(1)
        bod = bods.first
        expect(bod.name).to eq(ds_name)
        expect(bod.operation).to eq(Ddr::Batch::BatchObjectDatastream::OPERATION_ADDUPDATE)
        expect(bod.payload).to eq(file_path)
        expect(bod.payload_type).to eq(Ddr::Batch::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME)
        expect(bod.checksum).to be_nil
        expect(bod.checksum_type).to be_nil
      end
    end
    describe "checksum provided" do
      let(:service_args) { base_service_args.merge(checksum_service_args) }
      it "creates an appropriate batch object datastream for the update batch object" do
        batch_object = service.call
        bods = batch_object.batch_object_datastreams
        expect(bods.size).to eq(1)
        bod = bods.first
        expect(bod.name).to eq(ds_name)
        expect(bod.operation).to eq(Ddr::Batch::BatchObjectDatastream::OPERATION_ADDUPDATE)
        expect(bod.payload).to eq(file_path)
        expect(bod.payload_type).to eq(Ddr::Batch::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME)
        expect(bod.checksum).to eq(checksum)
        expect(bod.checksum_type).to eq(Ddr::Datastreams::CHECKSUM_TYPE_SHA1)
      end
    end
  end

end
