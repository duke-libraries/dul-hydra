#
# AdminPolicy does not subclass DulHydra::Models::Base
# b/c Hydra::AdminPolicy provides all the datastreams it needs.
#
class AdminPolicy < Hydra::AdminPolicy

  include ActiveFedora::Auditable
  include DulHydra::Models::Licensable

  delegate :default_license_title, to: DulHydra::Datastreams::DEFAULT_RIGHTS, at: [:license, :title], multiple: false
  delegate :default_license_description, to: DulHydra::Datastreams::DEFAULT_RIGHTS, at: [:license, :description], multiple: false
  delegate :default_license_url, to: DulHydra::Datastreams::DEFAULT_RIGHTS, at: [:license, :url], multiple: false

  APO_NAMESPACE = "duke-apo"

  def self.create_pid(suffix)
    "#{APO_NAMESPACE}:#{suffix}"
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

  def descriptive_metadata_terms
    [:title, :description]
  end

  # hydra-editor integration
  def terms_for_editing
    descriptive_metadata_terms
  end

  def to_solr(solr_doc=Hash.new, opts={})
    solr_doc = super(solr_doc, opts)
    solr_doc.merge!(DulHydra::IndexFields::TITLE => title || pid)
    solr_doc
  end

  def default_entities_for_permission(type, access)
    default_permissions.collect { |p| p[:name] if p[:type] == type and p[:access] == access }.compact
  end

  ["discover", "read", "edit"].each do |access|
    ["user", "group"].each do |type|
      define_method("default_#{access}_#{type}s") { default_entities_for_permission(type, access) }
    end
  end

  #
  # Load admin policy objects from YAML file
  #
  # YAML content should be a list of hashes, each of which should
  # consist of attributes that can be passed to the AdminPolicy
  # constructor.  Be sure to use the symbol syntax for hash keys.
  #
  # Example:
  #
  # - :pid: 'duke-apo:VicaCollection'
  #   :title: AdminPolicy governing objects associated with the Vica collection
  #   :permissions:
  #     - :type: group
  #       :name: registered
  #       :access: read
  #   :default_permissions:
  #     - :type: group
  #       :name: registered
  #       :access: read
  #   :default_license_title: Copyright and Use
  #   :default_license_description: The materials in this collection are made available ...
  #
  def self.load_policies(file_path)
    YAML.load_file(file_path).each do |attrs|
      begin
        apo = AdminPolicy.find(attrs[:pid])
      rescue ActiveFedora::ObjectNotFoundError
        begin
          apo = AdminPolicy.create(attrs)
        rescue ActiveFedora::UnknownAttributeError => e
          logger.error "AdminPolicy not created: #{e}"
        else
          logger.info "AdminPolicy #{apo.pid} created."
        end
      else
        logger.warn "AdminPolicy #{apo.pid} exists -- will not re-create."
      end
    end      
  end

end
