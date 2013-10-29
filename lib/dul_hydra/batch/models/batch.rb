module DulHydra::Batch::Models
  
  class Batch < ActiveRecord::Base
    attr_accessible :description, :name, :user
    belongs_to :user, :inverse_of => :batches
    has_many :batch_objects, :inverse_of => :batch, :dependent => :destroy
    has_many :batch_runs, :inverse_of => :batch, :dependent => :destroy

    def validate
      errors = []
      batch_objects.each { |object| errors << object.validate }
      errors.flatten
    end
    
  end
  
end