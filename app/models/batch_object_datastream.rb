class BatchObjectDatastream < ActiveRecord::Base
  attr_accessible :name, :operation, :payload, :payload_type
  belongs_to :batch_object, :inverse_of => :batch_object_datastreams
end
