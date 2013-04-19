class Batch < ActiveRecord::Base
  attr_accessible :description, :name
  has_many :batch_objects, :inverse_of => :batch
  has_many :batch_runs, :inverse_of => :batch
end
