class TestModel < DulHydra::Models::Base
end

class TestContent < TestModel
  include DulHydra::Models::HasContent
end

class TestParent < TestModel
  has_many :children, :property => :is_part_of, :class_name => 'TestModel', :inbound => true 
end

class TestChild < TestModel
  belongs_to :parent, :property => :is_part_of, :class_name => 'TestModel'
end

