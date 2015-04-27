module DulHydra::Batch::Models

  class BatchObjectDatastream < ActiveRecord::Base
#    attr_accessible :name, :operation, :payload, :payload_type, :checksum, :checksum_type, :batch_object
    belongs_to :batch_object, :inverse_of => :batch_object_datastreams

    DATASTREAMS = [ Ddr::Datastreams::CONTENT,
                    Ddr::Datastreams::DESC_METADATA,
                    Ddr::Datastreams::RIGHTS_METADATA ]

    OPERATION_ADD = "ADD" # add this datastream to the object -- considered an error if datastream already exists
    OPERATION_ADDUPDATE = "ADDUPDATE" # add this datastream to or update this datastream in the object
    OPERATION_UPDATE = "UPDATE" # update this datastream in the object -- considered an error if datastream does not already exist
    OPERATION_DELETE = "DELETE" # delete this datastream from the object -- considered an error if datastream does not exist

    PAYLOAD_TYPE_BYTES = "BYTES"
    PAYLOAD_TYPE_FILENAME = "FILENAME"

    PAYLOAD_TYPES = [ PAYLOAD_TYPE_BYTES, PAYLOAD_TYPE_FILENAME ]
  end

end
