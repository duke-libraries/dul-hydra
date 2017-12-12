class UpdateContentMediaType

  def self.call(*args)
    event = ActiveSupport::Notifications::Event.new(*args)
    obj = ActiveFedora::Base.find(event.payload[:pid])
    if obj.techmd.media_type.length == 1 &&
       obj.techmd.media_type.first != obj.content.mimeType
      obj.content.mimeType = obj.techmd.media_type.first
      obj.save!(summary: "Content media type updated from FITS information")
    end
  end

end
