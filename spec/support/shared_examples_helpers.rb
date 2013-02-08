module SharedExamplesHelpers

  def controller_object_class
    Object.const_get(controller_object_class_name)
  end

  def controller_object_class_name
    described_class.to_s.sub("Controller", "").singularize
  end

  def controller_object_class_symbol
    controller_object_class_name.downcase.to_sym
  end

  def described_class_symbol
    described_class_name.to_sym
  end

  def described_class_name
    described_class.to_s.downcase
  end

  def create_described_class_instance(apo = true)
    s = apo ? "#{described_class_name}_has_apo" : described_class_name
    FactoryGirl.create(s.to_sym)
  end

end
