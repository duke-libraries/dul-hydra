ActiveFedora::Base.class_eval do

  def can_have_attachments?
    # XXX Should probably test existence of association on :attachments
    self.is_a? DulHydra::HasAttachments
  end

  def has_attachments?
    can_have_attachments? && attachments.size > 0
  end

  def can_have_children?
    # DulHydra::HasChildren doesn't implement the has_many :children association
    # In active-fedora 7, we can write !association(:children).nil?
    !self.class.reflect_on_association(:children).nil?
  end

  def has_children?
    can_have_children? and children.size > 0
  end

  def can_have_preservation_events?
    self.is_a? DulHydra::HasPreservationEvents
  end

  def has_preservation_events?
    can_have_preservation_events? && preservation_events.size > 0
  end

  def can_have_content?
    self.is_a? DulHydra::HasContent
  end
    
  def has_content?
    false # DulHydra::HasContent implements #has_content?
  end

  def has_content_metadata?
    self.is_a?(DulHydra::HasContentMetadata) && self.datastreams[DulHydra::Datastreams::CONTENT_METADATA].has_content?
  end

  def describable?
    self.is_a? DulHydra::Describable
  end

  def governable?
    self.is_a? DulHydra::Governable
  end

  def has_admin_policy?
    governable? && admin_policy.present?
  end

  def has_rights_metadata?
    ds = self.datastreams[DulHydra::Datastreams::RIGHTS_METADATA]
    ds && ds.size && ds.size > 0
  end
  
  def can_have_thumbnail?
    self.is_a? DulHydra::HasThumbnail
  end

  def has_thumbnail?
    false # DulHydra::HasThumbnail implements #has_thumbnail?
  end

  def safe_id
    id.sub(/:/, "-")
  end

end
