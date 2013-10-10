DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  Blacklight.add_routes(self)

  devise_for :users

  mount FcrepoAdmin::Engine => '/fcrepo', :as=> 'fcrepo_admin'

  resources :objects, :only => :show do
    member do
      # get 'attachments'
      get 'collection_info'
      get 'download' => 'downloads#show'
      get 'preservation_events'
      get 'thumbnail' => 'thumbnail#show'
    end
  end

  resources :preservation_events, :only => :show

  resources :export_sets do
    member do
      post 'archive'
      delete 'archive'
    end
  end
  
  resources :batches do
    member do
      get 'procezz'
      get 'validate'
    end
    resources :batch_runs
    resources :batch_objects do
      resources :batch_object_datastreams
      resources :batch_object_relationships
    end
  end

  resources :admin_policies, :only => [:edit, :update]
  
end
