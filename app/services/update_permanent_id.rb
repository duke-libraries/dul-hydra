class UpdatePermanentId

  def self.call(object_or_id)
    obj = case object_or_id
          when ActiveFedora::Base
            object_or_id
          when String
            ActiveFedora::Base.find(object_or_id)
          else
            raise TypeError, "#{object_or_id.class} is not expected."
          end
    if identifier = PermanentId.assigned(obj)
      identifier.set_status!(obj)
    end
  end

end
