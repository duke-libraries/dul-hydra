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

  def describable?
    self.is_a?(DulHydra::Models::Describable)
  end
  
  def has_children?
    self.class.reflect_on_association(:children) && self.children.size > 0
  end

  def has_thumbnail?
    self.is_a?(DulHydra::Models::HasThumbnail) && self.datastreams[DulHydra::Datastreams::THUMBNAIL].has_content?
  end

  def has_parent?
    self.class.reflect_on_association(:parent) && self.parent
  end

  def safe_id
    id.sub(/:/, "-")
  end

end
