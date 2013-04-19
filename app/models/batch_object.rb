class BatchObject < ActiveRecord::Base
  attr_accessible :admin_policy, :identifier, :label, :model, :operation, :parent, :pid, :target_for
  belongs_to :batch, :inverse_of => :batch_objects
  has_many :batch_object_datastreams, :inverse_of => :batch_object
end
