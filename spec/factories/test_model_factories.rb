class TestModel < Ddr::Models::Base
end

class TestContent < TestModel
  include Ddr::Models::HasContent
end

class TestParent < TestModel
  include Ddr::Models::HasChildren
  has_many :children,
           predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf,
           class_name: 'TestChild'
end

class TestChild < TestModel
  belongs_to :parent,
             predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf,
             class_name: 'TestParent'
end

class TestModelOmnibus < TestModel
  include Ddr::Models::Governable
  include Ddr::Models::HasContent
  include Ddr::Models::HasAttachments
  has_many :children,
           predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf,
           class_name: 'TestChild'
  belongs_to :parent,
             predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf,
             class_name: 'TestParent'
end

FactoryGirl.define do

  factory :test_model do
    dc_title [ "DulHydra Test Object" ]
    sequence(:dc_identifier) { |n| [ "test%05d" % n ] }
  end

  factory :test_parent do
    dc_title [ "DulHydra Test Parent Object" ]
    sequence(:dc_identifier) { |n| [ "testparent%05d" % n ] }

    factory :test_parent_has_children do
      transient do
        child_count 3
      end
      after(:create) do |parent, evaluator|
        FactoryGirl.create_list(:test_child, evaluator.child_count, :parent => parent)
      end
    end
  end

  factory :test_child do
    dc_title [ "DulHydra Test Child Object" ]
    sequence(:dc_identifier) { |n| [ "testchild%05d" % n ] }

    factory :test_child_has_parent do
      association :parent, :factory => :test_parent
    end
  end

  factory :test_content do
    dc_title [ "DulHydra Test Content Object" ]
    sequence(:dc_identifier) { |n| [ "testcontent%05d" % n ] }
    after(:build) do |c|
      c.upload File.new(File.join(Rails.root, "spec", "fixtures", "imageA.tif"))
    end

    factory :test_content_with_fixity_check do
      after(:create) { |c| c.fixity_check! }
    end
  end

  factory :test_model_omnibus do
    dc_title [ "DulHydra Test Omnibus Object" ]
    sequence(:dc_identifier) { |n| [ "test%05d" % n ] }
    after(:build) do |c|
      c.upload File.new(File.join(Rails.root, "spec", "fixtures", "imageA.tif"))
    end
  end

end

