DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  Blacklight.add_routes(self)

  devise_for :users

  mount FcrepoAdmin::Engine => '/fcrepo', :as=> 'fcrepo_admin'

  scope "catalog/:id" do
    get 'collection-info' => 'collections#show'
    get 'download' => 'downloads#show'
    get 'preservation_events' => 'preservation_events#index'
    get 'thumbnail' => 'thumbnail#show'
  end

  resources :preservation_events, :only => :show

  # scope "preservation_events/:id" do
  #   get 'premis' => 'preservation_events#premis'
  # end

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
