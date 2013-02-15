DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  # # Model index views
  # match '/collections' => 'collections#index', :defaults => {:model => 'Collection'}
  # match '/items' => 'items#index', :defaults => {:model => 'Item'}
  # match '/components' => 'components#index', :defaults => {:model => 'Component'}

  # Datastreams
  match '/catalog/:object_id/datastreams' => 'datastreams#index', :as => 'datastreams'
  match '/catalog/:object_id/datastreams/:id' => 'datastreams#show', :as => 'datastream'
  match '/catalog/:object_id/datastreams/:id/content' => 'datastreams#content', :as => 'datastream_content'

  # # Related objects
  # match '/catalog/:object_id/parts' => 'related_objects#index', :default => {:rel => :is_part_of_s}
  # match '/catalog/:object_id/members' => 'related_objects#index', :default => {:rel => :is_member_of_s}
  
  # # Preservation events
  # match '/catalog/:object_id/preservation_events' = > 'preservation_events#index'
  # match '/catalog/:object_id/preservation_events/:id' => 'preservation_events#show'

  # # DulHydra objects
  # [:collections, :items, :components].each do |m|
  #   resources m, :only => [:index, :show]
  # end

  Blacklight.add_routes(self)
  # HydraHead.add_routes(self)

  devise_for :users
  
end
