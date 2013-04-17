module DulHydra::Models
  class Validation
    attr_accessor :errors
    
    def initialize()
      @errors = []
    end
    
    def valid?()
      @errors.empty?
    end
    
  end
end