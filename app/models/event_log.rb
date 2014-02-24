class EventLog < ActiveRecord::Base
  
  belongs_to :user, inverse_of: :event_logs
  
  validates_presence_of :event_date_time, :agent_type, :action, :model, :object_identifier, :application_version
  validate :agent_type_must_be_valid
  validate :action_must_be_valid
  validates_presence_of :user, if: :person_event?
  validates_presence_of :software_agent_value, if: :software_event?
  
  def self.agent_types
    AgentTypes.values
  end
  
  def self.actions
    Actions.values
  end
  
  def person_event?
    agent_type == AgentTypes::PERSON
  end
  
  def software_event?
    agent_type == AgentTypes::SOFTWARE
  end

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
  
  private
  
  def agent_type_must_be_valid
    unless EventLog.agent_types.include?(agent_type)
      errors.add(:agent_type, I18n.t('dul_hydra.event_logs.alerts.agent_type.invalid') % agent_type)
    end
  end

  def action_must_be_valid
    unless EventLog.actions.include?(action)
      errors.add(:action, I18n.t('dul_hydra.event_logs.alerts.action.invalid') % action)
    end
  end
  
end