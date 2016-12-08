require 'ezid-client'

class PermanentId < Ezid::Identifier

  class Error < DulHydra::Error; end
  class ObjectNotPersisted < Error; end
  class AlreadyAssigned < Error; end

  DEFAULT_STATUS   = Ezid::Status::RESERVED
  DEFAULT_EXPORT   = "no"
  DEFAULT_PROFILE  = "dc"
  DEFAULT_TARGET   = "https://repository.duke.edu/id/%s"
  FCREPO3_PID      = "fcrepo3.pid".freeze

  self.defaults = {
    profile: "dc",
    export:  "no",
    status:  DEFAULT_STATUS,
  }

  # @return [PermanentId] the permanent id assigned
  def self.assign!(obj, ark: nil)
    if obj.new_record?
      raise ObjectNotPersisted,
            "Object must be persisted prior to permanent id assignment."
    end
    if obj.permanent_id
      raise AlreadyAssigned,
            "Object #{obj.id} has already been assigned permanent id \"#{obj.permanent_id}\"."
    end
    identifier = ark ? find(ark) : mint
    obj.reload
    obj.permanent_id = identifier.id
    obj.save(validate: false)
    identifier.set_metadata!(obj)
  end

  # @return
  def self.assigned(obj)
    find(obj.permanent_id) if obj.permanent_id
  end

  # @raise [Ezid::Error] on EZID client or server error
  def set_metadata!(obj)
    set_metadata(obj)
    save
  end

  def set_metadata(obj)
    set_target
    set_status(obj)
    set_repo_id(obj)
  end

  def set_target
    self.target = DEFAULT_TARGET % id
  end

  def set_repo_id(obj)
    self.repo_id = obj.id
  end

  def repo_id=(val)
    if repo_id
      raise Error, "#{repo_id_field} already set to \"#{repo_id}\", cannot change."
    end
    self[repo_id_field] = val
  end

  def repo_id
    self[repo_id_field]
  end

  def repo_id_field
    FCREPO3_PID
  end

  def set_status(obj)
    if obj.published? && !public?
      public!
    elsif obj.unpublished? && public?
      unavailable!("not published")
    end
  end

end
