class SolrDocument
  include Blacklight::Solr::Document
  include Ddr::Models::SolrDocument

  use_extension(Hydra::ContentNegotiation)
end
