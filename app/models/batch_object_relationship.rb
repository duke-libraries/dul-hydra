class BatchObjectRelationship < ActiveRecord::Base
  attr_accessible :name, :object, :object_type, :operation
  belongs_to :batch_object, :inverse_of => :batch_object_relationships

  OPERATION_ADD = "ADD"
  OPERATION_UPDATE = "UPDATE"
  OPERATION_DELETE = "DELETE"
  
  OBJECT_TYPE_PID = "PID"

  OBJECT_TYPES = [ OBJECT_TYPE_PID ]
  
end
