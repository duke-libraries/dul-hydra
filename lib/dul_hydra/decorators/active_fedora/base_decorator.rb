ActiveFedora::Base.class_eval do

  def self.add_association_methods
    [:attachments, :children, :parent].each do |a|
      define_method("has_#{a}?".to_sym) do
        # ActiveFedora 7.0 will add an #association(name) instance method to AF::Base
        # so this can be rewritten as:
        #
        # !association(a).nil?
        #
        !self.class.reflect_on_association(a).nil?
      end
    end
  end

  add_association_methods

  def has_preservation_events?
    self.is_a?(DulHydra::Models::HasPreservationEvents)
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

  def governable?
    self.is_a?(DulHydra::Models::Governable)
  end

  def has_admin_policy?
    governable? && admin_policy.present?
  end

  def has_rights_metadata?
    ds = self.datastreams[DulHydra::Datastreams::RIGHTS_METADATA]
    ds && ds.size && ds.size > 0
  end
  
  def has_thumbnail?
    self.is_a?(DulHydra::Models::HasThumbnail) && self.datastreams[DulHydra::Datastreams::THUMBNAIL].has_content?
  end

  def safe_id
    id.sub(/:/, "-")
  end

end
