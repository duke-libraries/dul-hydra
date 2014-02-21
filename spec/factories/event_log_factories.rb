FactoryGirl.define do
  
  factory :event_log do
    event_date_time DateTime.now
    model "TestModel"
    sequence(:object_identifier) { |n| "test:#{n}"}
    application_version "0.0.0"    

    trait :person do
      agent_type EventLog::AgentTypes::PERSON
      user 
    end
    
    trait :software do
      agent_type EventLog::AgentTypes::SOFTWARE
      software_agent_value "software_agent"
    end
    
    trait :create do
      action EventLog::Actions::CREATE
    end

    trait :update do
      action EventLog::Actions::UPDATE
    end
    
    trait :create do
      action EventLog::Actions::UPDATE
    end
    
    trait :create do
      action EventLog::Actions::UPDATE
    end

    factory :person_create_event_log, traits: [ :person, :create ]

    factory :software_create_event_log, traits: [ :software, :create ]

  end
  
end