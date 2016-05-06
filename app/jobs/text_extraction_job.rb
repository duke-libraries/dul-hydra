class TextExtractionJob
  @queue = :text_extraction

  EVENT_TYPE = :update
  EVENT_SUMMARY = "Text extraction"

  def self.perform(id)
    object = ActiveFedora::Base.find(id)
    text = TextExtraction.call(object.content)
    object.extractedText.content = text
    object.save!
    object.notify_event(EVENT_TYPE,
                        summary: EVENT_SUMMARY,
                        detail: "Text extracted from content file",
                        software: TextExtraction.software)
  rescue TextExtraction::NoTextError, TextExtraction::EncryptedDocumentError => e
    object.notify_event(EVENT_TYPE,
                        summary: EVENT_SUMMARY,
                        outcome: Ddr::Events::Event::FAILURE,
                        detail: e.message,
                        software: TextExtraction.software)
  end
end
