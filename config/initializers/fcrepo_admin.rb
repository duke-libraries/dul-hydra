module DulHydra
  class Application < Rails::Application
    config.before_initialize do
      FcrepoAdmin.read_only = true
      FcrepoAdmin.object_nav_items << :catalog
      FcrepoAdmin.association_collection_query_sort_param = "#{DulHydra::IndexFields::TITLE} asc"
    end
  end
end

