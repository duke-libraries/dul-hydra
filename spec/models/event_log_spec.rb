require 'spec_helper'

describe EventLog do
  
  after { User.destroy_all }
  
  context "validation" do
    it "has a valid factory" do
      expect(FactoryGirl.build(:person_create_event_log)).to be_valid
    end
    it "is invalid without an event date and time" do
      expect(FactoryGirl.build(:person_create_event_log, event_date_time: nil)).to_not be_valid      
    end
    it "is invalid without an agent type" do
      expect(FactoryGirl.build(:person_create_event_log, agent_type: nil)).to_not be_valid      
    end
    it "is invalid without an action" do
      expect(FactoryGirl.build(:person_create_event_log, action: nil)).to_not be_valid      
    end
    it "is invalid without a model" do
      expect(FactoryGirl.build(:person_create_event_log, model: nil)).to_not be_valid      
    end
    it "is invalid without an object identifier" do
      expect(FactoryGirl.build(:person_create_event_log, object_identifier: nil)).to_not be_valid      
    end
    it "is invalid without an application version" do
      expect(FactoryGirl.build(:person_create_event_log, application_version: nil)).to_not be_valid      
    end
    it "is invalid if the agent type is not in the defined list" do
      expect(FactoryGirl.build(:person_create_event_log, agent_type: "invalid")).to_not be_valid
    end
    it "is invalid if the action is not in the defined list" do
      expect(FactoryGirl.build(:person_create_event_log, action: "invalid")).to_not be_valid
    end
    
    context "person agent" do
      it "is invalid without a user" do
        expect(FactoryGirl.build(:person_create_event_log, user: nil)).to_not be_valid
      end
    end
    
    context "software agent" do
      it "is invalid without a software agent value" do
        expect(FactoryGirl.build(:software_create_event_log, software_agent_value: nil)).to_not be_valid
      end
    end
    
  end
  
end