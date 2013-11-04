module DulHydra::Batch::Models
  
  class IngestFolder
    extend ActiveModel::Naming
    include ActiveModel::Model
    include ActiveModel::Conversion
    
    def initialize(opts={})
      
    end
    
    def persisted?
      false
    end
    
    def dirpath=(dirpath)
      @dirpath = dirpath
    end
    
    def dirpath
      @dirpath
    end
    
  end
  
end