class AdminPolicy < ActiveFedora::Base

  include Hydra::AdminPolicyBehavior

  include ActiveFedora::Auditable
  include DulHydra::Describable
  include DulHydra::Licensable
  include DulHydra::EventLoggable
  include DulHydra::AccessControllable
  include DulHydra::Indexing
  include Hydra::Validations

  has_attributes :default_license_title, datastream: DulHydra::Datastreams::DEFAULT_RIGHTS, at: [:license, :title], multiple: false
  has_attributes :default_license_description, datastream: DulHydra::Datastreams::DEFAULT_RIGHTS, at: [:license, :description], multiple: false
  has_attributes :default_license_url, datastream: DulHydra::Datastreams::DEFAULT_RIGHTS, at: [:license, :url], multiple: false

  validates_presence_of :title
  validates_uniqueness_of :title, solr_name: DulHydra::IndexFields::TITLE

  def default_license
    if default_license_title.present? or default_license_description.present? or default_license_url.present?
      {title: default_license_title, description: default_license_description, url: default_license_url}
    end
  end

  def default_license=(new_license)
    raise ArgumentError unless new_license.is_a?(Hash)
    l = new_license.with_indifferent_access
    self.default_license_title = l[:title]
    self.default_license_description = l[:description]
    self.default_license_url = l[:url]
  end

  def set_initial_permissions(creator_user = nil)
    super
    # Grant read to authenticated users
    self.permissions_attributes = [{name: "registered", type: "group", access: "read"}]
  end

  def default_entities_for_permission(type, access)
    default_permissions.collect { |p| p[:name] if p[:type] == type and p[:access] == access }.compact
  end
  
  ["discover", "read", "edit"].each do |access|
    ["user", "group"].each do |type|
      define_method("default_#{access}_#{type}s") { default_entities_for_permission(type, access) }
    end
  end

end