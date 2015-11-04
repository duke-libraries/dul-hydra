class SearchBuilder < Blacklight::Solr::SearchBuilder

  include Ddr::Models::SearchBuilder

  delegate :acting_as_superuser?, to: :scope

  def gated_discovery_filters
    return [] if acting_as_superuser?
    super
  end

end
