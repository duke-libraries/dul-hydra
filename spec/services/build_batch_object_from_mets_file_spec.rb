require 'spec_helper'

RSpec.describe BuildBatchObjectFromMETSFile, type: :service, batch: true, mets_file: true do

  let(:collection) { Collection.new }
  let(:mets_filepath) { '/tmp/mets.xml' }
  let(:mets_file) { METSFile.new(mets_filepath, collection) }
  let(:display_formats) { { 'slideshow' => 'multi_image' } }
  let(:batch) { Ddr::Batch::Batch.new }
  let(:service) { BuildBatchObjectFromMETSFile.new(batch: batch, mets_file: mets_file, display_formats: display_formats) }

  before do
    allow(File).to receive(:read).with(mets_filepath) { sample_mets_xml }
    allow(Ddr::Utils).to receive(:pid_for_identifier).with('efghi01003', collection: collection) { 'test:7' }
    allow(Ddr::Utils).to receive(:pid_for_identifier).with('efghi010030010', model: 'Component') { 'test:19' }
    allow(Ddr::Utils).to receive(:pid_for_identifier).with('efghi010030020', model: 'Component') { 'test:20' }
  end

  context "batch object" do
    it "should create an UpdateBatchObject for the batch" do
      batch_object = service.call
      expect(batch_object).to be_a(Ddr::Batch::UpdateBatchObject)
      expect(batch_object.batch).to eq(batch)
    end
  end

  context "local id" do
    it "should clear and re-assign the local id" do
      batch_object = service.call
      attrs = batch_object.batch_object_attributes
      clear_attrs = attrs.where(datastream: 'adminMetadata',
                                operation: Ddr::Batch::BatchObjectAttribute::OPERATION_CLEAR,
                                name: 'local_id')
      add_attrs = attrs.where(datastream: 'adminMetadata',
                              operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD,
                              name: 'local_id',
                              value: 'efghi01003')
      expect(clear_attrs.size).to eq(1)
      expect(add_attrs.size).to eq(1)
      expect(clear_attrs.first.id).to be < add_attrs.first.id
    end
  end

  context "display format" do
    it "should clear and re-assign the display format" do
      batch_object = service.call
      attrs = batch_object.batch_object_attributes
      clear_attrs = attrs.where(datastream: 'adminMetadata',
                                operation: Ddr::Batch::BatchObjectAttribute::OPERATION_CLEAR,
                                name: 'display_format')
      add_attrs = attrs.where(datastream: 'adminMetadata',
                              operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD,
                              name: 'display_format',
                              value: 'multi_image')
      expect(clear_attrs.size).to eq(1)
      expect(add_attrs.size).to eq(1)
      expect(clear_attrs.first.id).to be < add_attrs.first.id
    end
  end

  context "descriptive metadata" do
    it "should clear and re-assign all descriptive metadata" do
      batch_object = service.call
      attrs = batch_object.batch_object_attributes
      clear_all_attrs = attrs.where(datastream: Ddr::Datastreams::DESC_METADATA,
                                    operation: Ddr::Batch::BatchObjectAttribute::OPERATION_CLEAR_ALL)
      add_attrs = attrs.where(datastream: Ddr::Datastreams::DESC_METADATA,
                              operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD).order('id')
      add_spatial_1_attrs = attrs.where(datastream: Ddr::Datastreams::DESC_METADATA,
                                        operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD,
                                        name: 'spatial',
                                        value: 'Durham County (NC)')
      add_spatial_2_attrs = attrs.where(datastream: Ddr::Datastreams::DESC_METADATA,
                                        operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD,
                                        name: 'spatial',
                                        value: 'Durham (NC)')
      expect(clear_all_attrs.size).to eq(1)
      expect(add_attrs.size).to eq(11)
      expect(clear_all_attrs.first.id).to be < add_attrs.first.id
      expect(add_spatial_1_attrs.size).to eq(1)
      expect(add_spatial_2_attrs.size).to eq(1)
    end
  end

  context "EAD ID" do
    it "should clear and re-assign the EAD ID" do
      batch_object = service.call
      attrs = batch_object.batch_object_attributes
      clear_attrs = attrs.where(datastream: 'adminMetadata',
                                operation: Ddr::Batch::BatchObjectAttribute::OPERATION_CLEAR,
                                name: 'ead_id')
      add_attrs = attrs.where(datastream: 'adminMetadata',
                              operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD,
                              name: 'ead_id',
                              value: 'abcdcollection')
      expect(clear_attrs.size).to eq(1)
      expect(add_attrs.size).to eq(1)
      expect(clear_attrs.first.id).to be < add_attrs.first.id
    end
  end

  context "ArchivesSpace ID" do
    it "should clear and re-assign the ArchivesSpace ID" do
      batch_object = service.call
      attrs = batch_object.batch_object_attributes
      clear_attrs = attrs.where(datastream: 'adminMetadata',
                                operation: Ddr::Batch::BatchObjectAttribute::OPERATION_CLEAR,
                                name: 'aspace_id')
      add_attrs = attrs.where(datastream: 'adminMetadata',
                              operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD,
                              name: 'aspace_id',
                              value: '123456abcdef654321')
      expect(clear_attrs.size).to eq(1)
      expect(add_attrs.size).to eq(1)
      expect(clear_attrs.first.id).to be < add_attrs.first.id
    end
  end

  context "structural metadata" do
    it "should populate the structural metadata datastream" do
      batch_object = service.call
      dss = batch_object.batch_object_datastreams
      add_update_dss = dss.where(name: Ddr::Datastreams::STRUCT_METADATA,
                                 operation: Ddr::Batch::BatchObjectDatastream::OPERATION_ADDUPDATE)
      expect(add_update_dss.size).to eq(1)
      expect(add_update_dss.first.payload).to be_equivalent_to(sample_xml_struct_metadata)
    end
  end

end
