module DulHydra::Batch::Models

  class BatchObjectRelationship < ActiveRecord::Base
#    attr_accessible :name, :object, :object_type, :operation, :batch_object
    belongs_to :batch_object, :inverse_of => :batch_object_relationships

    RELATIONSHIP_ADMIN_POLICY = "admin_policy"
    RELATIONSHIP_COLLECTION = "collection"
    RELATIONSHIP_PARENT = "parent"
    RELATIONSHIP_ITEM = "item"
    RELATIONSHIP_COMPONENT = "component"
    RELATIONSHIP_ATTACHED_TO = "attached_to"

    RELATIONSHIPS = [ RELATIONSHIP_ADMIN_POLICY, RELATIONSHIP_COLLECTION, RELATIONSHIP_PARENT, RELATIONSHIP_ITEM,
      RELATIONSHIP_COMPONENT, RELATIONSHIP_ATTACHED_TO ]

    OPERATION_ADD = "ADD"
    OPERATION_UPDATE = "UPDATE"
    OPERATION_DELETE = "DELETE"

    OBJECT_TYPE_PID = "PID"

    OBJECT_TYPES = [ OBJECT_TYPE_PID ]
  end

end
