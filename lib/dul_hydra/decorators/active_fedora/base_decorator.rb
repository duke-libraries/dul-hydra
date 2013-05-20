ActiveFedora::Base.class_eval do

  def has_preservation_events?
    self.is_a?(DulHydra::Models::HasPreservationEvents) && self.preservation_events.count > 0
  end

  def has_content?
    self.is_a?(DulHydra::Models::HasContent) && self.datastreams[DulHydra::Datastreams::CONTENT].has_content?
  end

end
