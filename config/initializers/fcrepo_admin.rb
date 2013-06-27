module DulHydra
  class Application < Rails::Application
    config.before_initialize do
      FcrepoAdmin.read_only = true
      FcrepoAdmin.association_collection_query_sort_param = "#{DulHydra::IndexFields::TITLE} asc"
    end
  end
end

