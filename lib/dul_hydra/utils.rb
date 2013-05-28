module DulHydra::Utils

  def self.ds_as_of_date_time(ds)
    ds.dsCreateDate.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
  end

  # Returns the reflection object for a given model name and relationship name
  # E.g., relationship_object_reflection("Item", "parent") returns the reflection object for
  # an Item's parent relationship.  This reflection object can then be used to obtain the
  # class of the relationship object using the reflection_object_class(reflection) method below.
  def self.relationship_object_reflection(model, relationship_name)
    reflection = nil
    if model
      begin
        reflections = model.constantize.reflections
      rescue NameError
        # nothing to do here except that we can't return the appropriate reflection
      else
        reflections.each do |reflect|
          if reflect[0].eql?(relationship_name.to_sym)
            reflection = reflect
          end
        end
      end
    end
    return reflection
  end

  # Returns the class associated with the :class_name attribute in the options of a reflection
  # E.g., reflection_object_class(relationship_object_reflection("Item", "parent")) returns the
  # Collection class.
  def self.reflection_object_class(reflection)
    reflection_object_model = nil
    klass = nil
    if reflection[1].options[:class_name]
      reflection_object_model = reflection[1].options[:class_name]
    else
      reflection_object_model = ActiveSupport::Inflector.camelize(reflection[0])
    end
    if reflection_object_model
      begin
        klass = reflection_object_model.constantize
      rescue NameError
        # nothing to do here except that we can't return the reflection object class
      end
    end
    return klass
  end
  
end
