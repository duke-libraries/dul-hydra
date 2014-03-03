DulHydra::Application.routes.draw do

  root :to => "catalog#index"
  Blacklight.add_routes(self)
  devise_for :users

  # http://railsadventures.wordpress.com/2012/10/07/routing-only-ajax-requests-in-ror/
  class XhrRequestConstraint
    def self.matches?(request)
      request.xhr?
    end
  end

  pid_constraint = {id: /[a-zA-Z0-9\-_]+:[a-zA-Z0-9\-_]+/}

  resources :objects, only: [:show], constraints: pid_constraint do
    member do
      get 'collection_info', constraints: XhrRequestConstraint
      get 'download' => 'downloads#show'
      get 'preservation_events', constraints: XhrRequestConstraint
      get 'thumbnail' => 'thumbnail#show'
      get 'datastreams/:datastream_id' => 'downloads#show', as: 'download_datastream'
      get 'upload' => 'uploads#show'
      patch 'upload' => 'uploads#update'
    end
  end

  resources :collections, only: [:new, :create]
  resources :admin_policies, only: [:new, :create]

  # other object tabs
  get '/objects/:id/:tab' => 'objects#show', 
      constraints: pid_constraint.merge(tab: /attachments|items|components/), 
      as: 'object_tab'

  # Hydra-editor for descriptive metadata
  scope '/objects/:id/descriptive_metadata', constraints: pid_constraint, as: 'record' do
    get '/' => 'objects#show', defaults: {tab: 'descriptive_metadata'}
    get 'edit' => 'objects#edit'
    patch '/' => 'objects#update'
  end

  scope '/objects/:id/permissions', constraints: pid_constraint, as: 'permissions' do
    get '/' => 'objects#show', defaults: {tab: 'permissions'}
    get 'edit' => 'permissions#edit'
    put '/' => 'permissions#update'
  end

  scope '/objects/:id/default_permissions', constraints: pid_constraint, as: 'default_permissions' do
    get '/' => 'objects#show', defaults: {tab: 'default_permissions'}
    get 'edit' => 'permissions#edit', defaults: {default_permissions: true}
    put '/' => 'permissions#update', defaults: {default_permissions: true}
  end

  scope '/objects/:id', constraints: pid_constraint do
    resources :attachments, only: [:new, :create]
  end

  resources :preservation_events, :only => :show, constraints: { id: /[1-9][0-9]*/ }

  resources :export_sets do
    member do
      get 'archive', as: 'download'
      patch 'archive'
      delete 'archive'
    end
  end
  
  resources :batches, :only => [:index, :show] do
    member do
      get 'procezz'
      get 'validate'
    end
    resources :batch_objects, :only => :index
  end
  
  resources :batch_objects, :only => :show do
    resources :batch_object_datastreams, :only => :index
    resources :batch_object_relationships, :only => :index
  end
  
  resources :ingest_folders, :only => [:new, :create, :show] do
    member do
      get 'procezz'
    end
  end

  resources :metadata_files, :only => [:new, :create, :show] do
    member do
      get 'procezz'
    end
  end
  
end
