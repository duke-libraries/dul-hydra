DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  # Datastreams
  # match '/catalog/:object_id/datastreams' => 'catalog#datastreams', :as => 'datastreams'
  # match '/catalog/:object_id/datastreams/:id' => 'catalog#datastream', :as => 'datastream'
  # match '/catalog/:object_id/datastreams/:id/content' => 'catalog#datastream_content', :as => 'datastream_content'

  # # Related objects
  # match '/catalog/:object_id/parts' => 'related_objects#index', :default => {:rel => :is_part_of_s}
  # match '/catalog/:object_id/members' => 'related_objects#index', :default => {:rel => :is_member_of_s}
  
  # Preservation events
  # match '/catalog/:object_id/preservation_events' => 'catalog#preservation_events', :as => 'preservation_events'
  # match '/catalog/:object_id/preservation_events/:id' => 'preservation_events#show'

  Blacklight.add_routes(self)

  devise_for :users

  namespace :catalog do
    scope ":object_id" do
      resources :datastreams, :only => [:index, :show]
      resources :preservation_events, :only => [:index, :show]
    end
  end
  
end
