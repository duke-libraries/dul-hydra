require 'spec_helper'

describe EventLog do
  
  after { User.destroy_all }

  context ".create_for_model_action" do
    after do
      ActiveFedora::Base.destroy_all
      EventLog.destroy_all
    end
    let(:object) { FactoryGirl.create(:test_model) }
    let(:user) { FactoryGirl.create(:user) }
    subject { EventLog.create_for_model_action(user: user, object: object, action: EventLog::Actions::CREATE) }
    its(:object_identifier) { should == object.pid }
    its(:agent_type) { should == EventLog::AgentTypes::PERSON }
    its(:event_date_time) { should == Time.parse(object.modified_date).localtime }
    its(:model) { should == object.class.to_s }
    its(:application_version) { should == "DulHydra #{DulHydra::VERSION}" }
  end
  
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
