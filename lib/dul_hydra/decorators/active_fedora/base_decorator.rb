ActiveFedora::Base.class_eval do

  def has_preservation_events?
    self.is_a?(DulHydra::Models::HasPreservationEvents) && self.preservation_events.size > 0
  end

  def has_content?
    self.is_a?(DulHydra::Models::HasContent) && self.datastreams[DulHydra::Datastreams::CONTENT].has_content?
  end

  def has_content_metadata?
    self.is_a?(DulHydra::Models::HasContentMetadata) && self.datastreams[DulHydra::Datastreams::CONTENT_METADATA].has_content?
  end

  def has_children?
    self.reflections.has_key?(:children) && self.children.size > 0
  end

end
