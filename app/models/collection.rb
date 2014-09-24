class Collection < DulHydra::Base
  
  include Hydra::AdminPolicyBehavior
  
  include DulHydra::HasChildren
  include DulHydra::HasAttachments

  has_attributes :default_license_title, datastream: DulHydra::Datastreams::DEFAULT_RIGHTS, at: [:license, :title], multiple: false
  has_attributes :default_license_description, datastream: DulHydra::Datastreams::DEFAULT_RIGHTS, at: [:license, :description], multiple: false
  has_attributes :default_license_url, datastream: DulHydra::Datastreams::DEFAULT_RIGHTS, at: [:license, :url], multiple: false

  has_many :children, property: :is_member_of_collection, class_name: 'Item'
  has_many :targets, property: :is_external_target_for, class_name: 'Target'

  alias_method :items, :children
  alias_method :item_ids, :child_ids

  validates_presence_of :title

  def components_from_solr
    outer = DulHydra::IndexFields::IS_PART_OF
    inner = DulHydra::IndexFields::INTERNAL_URI
    where = ActiveFedora::SolrService.construct_query_for_rel(:is_member_of_collection => internal_uri)
    query = "{!join to=#{outer} from=#{inner}}#{where}"
    filter = ActiveFedora::SolrService.construct_query_for_rel(:has_model => Component.to_class_uri)
    results = ActiveFedora::SolrService.query(query, fq: filter, rows: 100000)
    results.lazy.map {|doc| SolrDocument.new(doc)}
  end

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

  def default_entities_for_permission(type, access)
    default_permissions.collect { |p| p[:name] if p[:type] == type and p[:access] == access }.compact
  end
  
  ["discover", "read", "edit"].each do |access|
    ["user", "group"].each do |type|
      define_method("default_#{access}_#{type}s") { default_entities_for_permission(type, access) }
    end
  end

end
