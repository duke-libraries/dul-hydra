require 'ezid-client'

class PermanentId

  class Error < DulHydra::Error; end
  class AssignmentFailed < Error; end
  class RepoObjectNotPersisted < Error; end
  class AlreadyAssigned < AssignmentFailed; end
  class IdentifierNotAssigned < Error; end
  class IdentifierNotFound < Error; end

  PERMANENT_URL_BASE = "https://idn.duke.edu/".freeze
  DEFAULT_STATUS     = Ezid::Status::RESERVED
  DEFAULT_EXPORT     = "no".freeze
  DEFAULT_PROFILE    = "dc".freeze
  DEFAULT_TARGET     = "https://repository.duke.edu/id/%s"
  FCREPO3_PID        = "fcrepo3.pid".freeze
  DELETED            = "deleted".freeze
  DEACCESSIONED      = "deaccessioned".freeze

  class_attribute :identifier_class, :identifier_repo_id_field

  self.identifier_class = Ezid::Identifier
  self.identifier_class.defaults = {
    profile: DEFAULT_PROFILE,
    export:  DEFAULT_EXPORT,
    status:  DEFAULT_STATUS,
  }

  self.identifier_repo_id_field = FCREPO3_PID

  # ActiveSupport::Notifications event handler
  def self.call(*args)
    event = ActiveSupport::Notifications::Event.new(*args)
    repo_id, identifier_id, reason = event.payload.values_at(:pid, :permanent_id, :reason)
    case event.name
    when /^create/
      PermanentId.assign!(repo_id) if DulHydra.auto_assign_permanent_id
    when /workflow/
      PermanentId.update!(repo_id) if DulHydra.auto_update_permanent_id
    when /^deaccession/
      if DulHydra.auto_update_permanent_id && identifier_id
        PermanentId.deaccession!(repo_id, identifier_id, reason)
      end
    when /^destroy/
      if DulHydra.auto_update_permanent_id && identifier_id
        PermanentId.delete!(repo_id, identifier_id, reason)
      end
    end
  end

  def self.deaccession!(repo_object_or_id, identifier_or_id, reason = nil)
    new(repo_object_or_id, identifier_or_id).deaccession!(reason)
  end

  def self.delete!(repo_object_or_id, identifier_or_id, reason = nil)
    new(repo_object_or_id, identifier_or_id).delete!(reason)
  end

  def self.update!(repo_object_or_id)
    perm_id = new(repo_object_or_id)
    perm_id.update! if perm_id.assigned?
  end

  def self.assign!(repo_object_or_id, identifier_or_id = nil)
    new(repo_object_or_id, identifier_or_id).assign!
  end

  def self.assigned(repo_object_or_id)
    perm_id = new(repo_object_or_id)
    perm_id.assigned? ? perm_id : nil
  end

  def initialize(repo_object_or_id, identifier_or_id = nil)
    case repo_object_or_id
    when ActiveFedora::Base
      raise RepoObjectNotPersisted, "Repository object must be persisted." if repo_object_or_id.new_record?
      @repo_object = repo_object_or_id
    when String, nil
      @repo_id = repo_object_or_id
    else
      raise TypeError, "#{repo_object_or_id.class} is not expected as the first argument."
    end

    case identifier_or_id
    when identifier_class
      @identifier = identifier_or_id
    when String, nil
      @identifier_id = identifier_or_id
    else
      raise TypeError, "#{identifier_or_id.class} is not expected as the second argument."
    end
  end

  def repo_object
    @repo_object ||= ActiveFedora::Base.find(repo_id)
  end

  def repo_id
    @repo_id ||= @repo_object && @repo_object.id
  end

  def assign!(id = nil)
    ActiveSupport::Notifications.instrument("assign.permanent_id", pid: repo_object.id) do |payload|
      assign(id)
      software = [ "dul-hydra {DulHydra::VERSION}", Ezid::Client.version ].join("; ")
      detail = <<-EOS
Permanent ID:  #{repo_object.permanent_id}
Permanent URL: #{repo_object.permanent_url}

EZID Metadata:
#{identifier.metadata}
      EOS
      payload.merge!(summary: "Permanent ID assignment",
                     detail: detail,
                     software: software,
                     permanent_id: identifier.id)
    end
  end

  def assigned?
    repo_object.permanent_id
  end

  def update!
    ActiveSupport::Notifications.instrument("update.permanent_id", pid: repo_object.id) do |payload|
      update
      payload.merge!(permanent_id: identifier.id)
    end
  end

  def deaccession!(reason = nil)
    delete_or_make_unavailable(reason || DEACCESSIONED)
  end

  def delete!(reason = nil)
    delete_or_make_unavailable(reason || DELETED)
  end

  def identifier
    if @identifier.nil?
      if identifier_id
        @identifier = find_identifier(identifier_id)
      elsif assigned?
        @identifier = find_identifier(repo_object.permanent_id)
      end
    end
    @identifier
  end

  def identifier_id
    @identifier_id ||= @identifier && @identifier.id
  end

  def set_permanent_url
    repo_object.permanent_url = PERMANENT_URL_BASE + identifier.id
  end

  def set_metadata!
    set_metadata
    save
    self
  end

  def set_metadata
    set_target
    set_status
    set_identifier_repo_id
  end

  def set_target
    self.target = DEFAULT_TARGET % id
  end

  def set_identifier_repo_id
    self.identifier_repo_id = repo_object.id
  end

  def identifier_repo_id=(val)
    if identifier_repo_id
      raise Error, "Identifier repository id already set to \"#{identifier_repo_id}\"; cannot change."
    end
    self[identifier_repo_id_field] = val
  end

  def identifier_repo_id
    self[identifier_repo_id_field]
  end

  def set_status!
    save if set_status
  end

  def set_status
    if repo_object.published? && !public?
      public!
    elsif repo_object.unpublished? && public?
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
            "Cannot update identifier for repository object \"#{repo_object.id}\"; not assigned."
    end
    set_status!
  end

  def assign(id = nil)
    if assigned?
      raise AlreadyAssigned,
            "Repository object \"#{repo_object.id}\" has already been assigned permanent id \"#{repo_object.permanent_id}\"."
    end
    @identifier = case id
                  when identifier_class
                    id
                  when String
                    find_identifier(id)
                  when nil
                    mint_identifier
                  end
    repo_object.reload
    repo_object.permanent_id = identifier.id
    repo_object.permanent_url = PERMANENT_URL_BASE + identifier.id
    repo_object.save(validate: false)
    set_metadata!
  end

  def delete_or_make_unavailable(reason)
    if repo_id && identifier_repo_id && ( identifier_repo_id != repo_id )
      raise Error, "Identifier \"#{identifier_id}\" is assigned to a different repository object \"#{repo_id}\"."
    end
    if reserved?
      delete
    else
      unavailable!(reason) && save
    end
  end

end
