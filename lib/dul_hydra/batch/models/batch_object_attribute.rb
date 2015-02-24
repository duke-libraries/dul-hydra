module DulHydra::Batch::Models

  class BatchObjectAttribute < ActiveRecord::Base
    belongs_to :batch_object, :inverse_of => :batch_object_attributes

    OPERATION_ADD = "ADD"          # Add the provided value to the attribute
    OPERATION_DELETE = "DELETE"    # Delete the provided value from the attribute
    OPERATION_CLEAR = "CLEAR"      # Clear all values from the attribute

    VALUE_TYPE_STRING = "string"

    VALUE_TYPES = [ VALUE_TYPE_STRING ]  
  end

end