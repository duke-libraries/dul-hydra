class BuildBatchObjectFromDatastreamUpload

  attr_reader :batch, :checksum, :file_path, :datastream_name, :repo_id

  def initialize(batch:, checksum: nil, datastream_name:, file_path:, repo_id:)
    @batch = batch
    @checksum = checksum
    @datastream_name = datastream_name
    @file_path = file_path
    @repo_id = repo_id
  end

  def call
    create_update_object
  end

  def create_update_object
    update_object = Ddr::Batch::UpdateBatchObject.create(batch: batch, pid: repo_id)
    add_uploaded_datastream(update_object)
    update_object
  end

  def add_uploaded_datastream(batch_object)
    ds_attrs = { name: datastream_name,
                 operation: Ddr::Batch::BatchObjectDatastream::OPERATION_ADDUPDATE,
                 payload: file_path,
                 payload_type: Ddr::Batch::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME }
    if checksum.present?
      ds_attrs.merge!({ checksum: checksum,
                        checksum_type: Ddr::Datastreams::CHECKSUM_TYPE_SHA1 })
    end
    ds = Ddr::Batch::BatchObjectDatastream.create(ds_attrs)
    batch_object.batch_object_datastreams << ds
  end
end
