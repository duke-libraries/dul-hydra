class AssignPermanentId

  # @param object_or_id [ActiveFedora::Base, String] object or PID
  # @raise [TypeError, ActiveFedora::ObjectNotFoundError, PermanentId::Error]
  # @return [PermanentId] the assigned identifier, or `false` if
  #   the object already has a permanent id.
  def self.call(object_or_id)
    obj = case object_or_id
          when ActiveFedora::Base
            object_or_id
          when String
            ActiveFedora::Base.find(object_or_id)
          else
            raise TypeError, "#{object_or_id.class} is not expected."
          end
    begin
      PermanentId.assign!(obj)
    rescue PermanentId::AlreadyAssigned => e
      Rails.logger.warn e.message
      false
    end
  end

end
