class EventLog < ActiveRecord::Base
  
  belongs_to :user, inverse_of: :event_logs
  
  module AgentTypes
    PERSON = "person"
    SOFTWARE = "software"
    def self.all
      constants(false)
    end
    def self.values
      all.collect { |c| const_get(c) }
    end
  end
  
  module Actions
    CREATE = "create"
    UPDATE = "update"
    DELETE = "delete"
    DESTROY = "destroy"
    def self.all
      constants(false)
    end
    def self.values
      all.collect { |c| const_get(c) }
    end
  end
  
  validates_presence_of :event_date_time, :agent_type, :action, :model, :object_identifier, :application_version
  validates_inclusion_of :agent_type, in: AgentTypes::values
  validates_inclusion_of :action, in: Actions::values
  validates_presence_of :user, if: :person_event?
  validates_presence_of :software_agent_value, if: :software_event?
  
  def person_event?
    agent_type == AgentTypes::PERSON
  end
  
  def software_event?
    agent_type == AgentTypes::SOFTWARE
  end

end