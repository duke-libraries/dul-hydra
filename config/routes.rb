DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  # Model index views
  match '/collections' => 'catalog#model_index', :defaults => {:model => 'Collection'}, :as => 'collections'
  match '/items' => 'catalog#model_index', :defaults => {:model => 'Item'}, :as => 'items'
  match '/components' => 'catalog#model_index', :defaults => {:model => 'Component'}, :as => 'components'
  match '/admin_policies' => 'catalog#model_index', :defaults => {:model => 'AdminPolicy'}, :as => 'admin_policies'

  # Datastreams
  match '/catalog/:object_id/datastreams' => 'catalog#datastreams', :as => 'datastreams'
  match '/catalog/:object_id/datastreams/:id' => 'catalog#datastream', :as => 'datastream'
  match '/catalog/:object_id/datastreams/:id/content' => 'catalog#datastream_content', :as => 'datastream_content'

  # # Related objects
  # match '/catalog/:object_id/parts' => 'related_objects#index', :default => {:rel => :is_part_of_s}
  # match '/catalog/:object_id/members' => 'related_objects#index', :default => {:rel => :is_member_of_s}
  
  # Preservation events
  match '/catalog/:object_id/preservation_events' => 'catalog#preservation_events', :as => 'preservation_events'
  # match '/catalog/:object_id/preservation_events/:id' => 'preservation_events#show'

  # # DulHydra objects
  # [:collections, :items, :components].each do |m|
  #   resources m, :only => [:index, :show]
  # end

  Blacklight.add_routes(self)
  # HydraHead.add_routes(self)

  devise_for :users
  
end
