class Attachment < DulHydra::Base

  include DulHydra::HasContent
  
  belongs_to :attached_to, 
             :property => :is_attached_to, 
             :class_name => 'ActiveFedora::Base'

  validates :title, presence: true
  # XXX With Rubydora 1.7.1 can change to
  # validates :content, presence: true
  validates :content, has_content: true
  validates :attached_to, presence: true

  def set_initial_permissions(user_creator = nil)
    if attached_to
      if attached_to.has_admin_policy?
        # XXX In active-fedora 7.0 can do
        # self.admin_policy = attached_to.admin_policy
        self.admin_policy_id = attached_to.admin_policy_id if attached_to.has_admin_policy?
      else      
        self.permissions_attributes = attached_to.permissions.collect { |p| p.vals }
      end
    end
    if user_creator
      self.permissions_attributes = [{type: 'user', name: user_creator.user_key, access: 'edit'}]
    end
  end
  
end
