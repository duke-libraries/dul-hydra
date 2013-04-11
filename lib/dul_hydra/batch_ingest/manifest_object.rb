module DulHydra::BatchIngest
  class ManifestObject
    
    attr_accessor :identifier,
                  :contentdm,
                  :descmetadatasource,
                  :digitizationguide,
                  :fmpexport,
                  :label,
                  :marcxml,
                  :metadata,
                  :parentautoidlength,
                  :parentid,
                  :parentmaster,
                  :tripodmets
    
    def initialize(object_attributes_hash)
      object_attributes_hash.each { |key, value| instance_variable_set "@#{key}", value }
    end
    
    def to_hash()
      object_hash = {}
      instance_variables.each { |var| object_hash[var.to_s.gsub('@','')] = instance_variable_get var }
      return object_hash
    end
    
    def to_yaml()
      self.to_hash.to_yaml
    end
  end
end