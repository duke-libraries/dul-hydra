class BatchObjectDatastream < ActiveRecord::Base
  attr_accessible :name, :operation, :payload, :payload_type
  belongs_to :batch_object, :inverse_of => :batch_object_datastreams
  
  ADD = "ADD" # add this datastream to the object -- considered an error if datastream already exists
  ADDUPDATE = "ADDUPDATE" # add this datastream to or update this datastream in the object
  UPDATE = "UPDATE" # update this datastream in the object -- considered an error if datastream does not already exist
  DELETE = "DELETE" # delete this datastream from the object -- considered an error if datastream does not exist
  
  BYTES = "BYTES"
  FILENAME = "FILENAME"
  
  PAYLOAD_TYPES = [ BYTES, FILENAME ]
  
end
