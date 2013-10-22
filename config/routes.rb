DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  Blacklight.add_routes(self)

  devise_for :users

  mount FcrepoAdmin::Engine => '/fcrepo', as: 'fcrepo_admin'
  #mount HydraEditor::Engine => '/', as: 'hydra_editor'

  resources :objects, only: [:show] do
    member do
      get 'collection_info'
      get 'download' => 'downloads#show'
      get 'preservation_events'
      get 'thumbnail' => 'thumbnail#show'
      get 'datastreams/:datastream_id' => 'downloads#show', as: 'download_datastream'
    end
  end

  # hydra-editor for descriptive metadata
  resources :objects, only: [:edit, :update], as: 'records'
  # scope '/objects/:id/metadata', as: 'records' do 
  #   get 'edit' => 'objects#edit'
  #   put '/' => 'objects#update'
  # end
    
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
