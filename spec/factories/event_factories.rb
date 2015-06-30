FactoryGirl.define do

  factory :event do
    sequence(:pid) { |n| "test:#{n}"}

    factory :fixity_check_event, class: Ddr::Events::FixityCheckEvent
    factory :virus_check_event, class: Ddr::Events::VirusCheckEvent

  end

end
