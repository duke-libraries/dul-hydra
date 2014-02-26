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
    UPLOAD = "upload"
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

  def self.create_for_model_action(args)
    object = args.delete(:object)
    raise DulHydra::Error, ":object argument missing" unless object
    e = new(args)
    e.event_date_time = Time.parse(object.modified_date).localtime unless e.event_date_time
    e.object_identifier = object.id
    e.model = object.class.to_s
    e.agent_type = e.user ? AgentTypes::PERSON : AgentTypes::SOFTWARE
    e.application_version = "DulHydra #{DulHydra::VERSION}"
    e.save!
    e
  end

end
