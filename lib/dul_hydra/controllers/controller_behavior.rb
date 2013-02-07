module DulHydra::Controllers
  module ControllerBehavior

    def model_class
      self.class.name.sub("Controller", "").singularize
    end

    def model_instance_var
      self.instance_variable_get("@#{model_class.downcase}")
    end

  end
end
