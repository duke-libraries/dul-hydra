DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  Blacklight.add_routes(self)
  HydraHead.add_routes(self)

  devise_for :users

  # DulHydra objects
  resources :collections, :items, :components do
    get 'datastreams'
    get 'datastreams/:datastream_id', :action => 'datastream'
    get 'datastreams/:datastream_id/content', :action => 'datastream_content'
  end
  
end
