DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  Blacklight.add_routes(self)
  HydraHead.add_routes(self)

  devise_for :users

  # Datastreams
  match '/catalog/:object_id/datastreams' => 'datastreams#index', :as => 'datastreams'
  match '/catalog/:object_id/datastreams/:id' => 'datastreams#show', :as => 'datastream'
  match '/catalog/:object_id/datastreams/:id/content' => 'datastreams#content', :as => 'datastream_content'

  # DulHydra objects
  resources :collections
  resources :items
  resources :components
  
end
