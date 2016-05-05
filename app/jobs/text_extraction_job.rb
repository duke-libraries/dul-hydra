class TextExtractionJob
  @queue = :text_extraction

  EVENT_SUMMARY = "Text extracted from content file"
  EVENT_TYPE = :update

  def self.perform(id)
    object = ActiveFedora::Base.find(id)
    text = TextExtraction.call(object.content)
    object.extractedText.content = text
    object.save!
    object.notify_event(EVENT_TYPE,
                        summary: EVENT_SUMMARY,
                        software: TextExtraction.software)
  end
end
