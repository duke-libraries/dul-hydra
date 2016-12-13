require 'ezid-client'

class PermanentId

  class Error < DulHydra::Error; end
  class AssignmentFailed < Error; end
  class ObjectNotPersisted < Error; end
  class AlreadyAssigned < AssignmentFailed; end
  class IdentifierNotAssigned < Error; end
  class IdentifierNotFound < Error; end

  DEFAULT_STATUS   = Ezid::Status::RESERVED
  DEFAULT_EXPORT   = "no"
  DEFAULT_PROFILE  = "dc"
  DEFAULT_TARGET   = "https://repository.duke.edu/id/%s"
  FCREPO3_PID      = "fcrepo3.pid".freeze

  class_attribute :identifier_class

  self.identifier_class = Ezid::Identifier
  self.identifier_class.defaults = {
    profile: "dc",
    export:  "no",
    status:  DEFAULT_STATUS,
  }

  def self.update!(object_or_id)
    perm_id = new(object_or_id)
    perm_id.update! if perm_id.assigned?
  end

  # @return [PermanentId] the permanent id assigned to the object
  def self.assign!(object_or_id, ark = nil)
    new(object_or_id).assign!(ark)
  end

  # @return [PermanentId] the permanent id previously assigned to the object,
  #   or nil, if not assigned.
  def self.assigned(object_or_id)
    perm_id = new(object_or_id)
    perm_id.assigned? ? perm_id : nil
  end

  attr_reader :object

  def initialize(object_or_id)
    object = case object_or_id
             when ActiveFedora::Base
               if object_or_id.new_record?
                 raise ObjectNotPersisted, "Object must be persisted."
               end
               object_or_id
             when String
               ActiveFedora::Base.find(object_or_id)
             else
               raise TypeError, "#{object_or_id.class} is not expected."
             end
    @object = object
  end

  def assign!(id = nil)
    ActiveSupport::Notifications.instrument("assign.permanent_id", pid: object.id) do |payload|
      assign(id)
      payload.merge(status: status, target: target, permanent_id: identifier.id)
    end
  end

  def assigned?
    object.permanent_id
  end

  def update!
    ActiveSupport::Notifications.instrument("update.permanent_id", pid: object.id) do |payload|
      update
      payload.merge(status: status, permanent_id: identifier.id)
    end
  end

  def identifier
    if @identifier.nil? && assigned?
      @identifier = find_identifier(object.permanent_id)
    end
    @identifier
  end

  # @raise [Ezid::Error] on EZID client or server error
  def set_metadata!
    set_metadata
    save
    self
  end

  def set_metadata
    set_target
    set_status
    set_repo_id
  end

  def set_target
    self.target = DEFAULT_TARGET % id
  end

  def set_repo_id
    self.repo_id = object.id
  end

  def repo_id=(val)
    if repo_id
      raise Error, "Identifier repository id already set to \"#{repo_id}\"; cannot change."
    end
    self[repo_id_field] = val
  end

  def repo_id
    self[repo_id_field]
  end

  def repo_id_field
    FCREPO3_PID
  end

  def set_status!
    save if set_status
  end

  def set_status
    if object.published? && !public?
      public!
    elsif object.unpublished? && public?
      unavailable!("not published")
    end
  end

  protected

  def method_missing(name, *args, &block)
    identifier.send(name, *args, &block)
  end

  private

  def find_identifier(ark)
    identifier_class.find(ark)
  rescue Ezid::IdentifierNotFoundError => e
    raise IdentifierNotFound, e.message
  end

  def mint_identifier(*args)
    identifier_class.mint(*args)
  end

  def update
    if !assigned?
      raise IdentifierNotAssigned,
            "Cannot update identifier for object \"#{object.id}\"; not assigned."
    end
    set_status!
  end

  def assign(id = nil)
    if assigned?
      raise AlreadyAssigned,
            "Object \"#{object.id}\" has already been assigned permanent id \"#{object.permanent_id}\"."
    end
    @identifier = case id
                  when identifier_class
                    id
                  when String
                    find_identifier(id)
                  when nil
                    mint_identifier
                  end
    object.reload
    object.permanent_id = identifier.id
    object.save(validate: false)
    set_metadata!
  end

end
