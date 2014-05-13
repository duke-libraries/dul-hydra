require 'resque/server'

DulHydra::Application.routes.draw do

  root :to => "catalog#index"
  Blacklight.add_routes(self)
  devise_for :users

  def pid_constraint
    /[a-zA-Z0-9\-_]+:[a-zA-Z0-9\-_]+/
  end
  
  def tab_constraint
    /attachments|items|components|descriptive_metadata|permissions|default_permissions/
  end

  if defined?(DulHydra::ResqueAdmin)
    namespace :admin do
      constraints DulHydra::ResqueAdmin do
        mount Resque::Server, at: '/queues'
      end
    end
  end

  def rights_routes
    get 'permissions'
    patch 'permissions'
  end

  def content_routes
    get 'upload'
    patch 'upload'
    get 'download' => 'downloads#show'
  end

  def tab_routes
    get ':tab' => '#show', constraints: {tab: tab_constraint}
  end

  def event_log_routes
    get 'preservation_events'
  end

  def thumbnail_routes
    get 'thumbnail' => 'thumbnail#show'
  end

  def datastream_routes
    get 'datastreams/:datastream_id' => 'downloads#show'
  end

  def policy_routes
    get 'default_permissions'
    patch 'default_permissions'
  end

  def repository_routes
    rights_routes
    event_log_routes
    datastream_routes
  end

  def repository_contraints
    {id: pid_constraint}
  end

  def no_repository_routes_for name
    no_routes = [:index, :destroy]
    no_routes += [:new, :create] if name == :targets
  end

  def repository_options name
    { except: no_repository_routes_for(name), 
      constraints: repository_contraints }
  end

  def repository_resource name
    resources name, repository_options(name) do
      member do
        repository_routes
        yield if block_given?
      end
    end
  end

  def repository_content_resource name
    repository_resource name do
      content_routes
    end
  end

  repository_resource :collections do
    get 'collection_info'
  end
  repository_resource :items
  repository_content_resource :components
  repository_content_resource :attachments
  repository_content_resource :targets
  resources :admin_policies, repository_options(:admin_policies) do
    member do
      rights_routes
      policy_routes
      datastream_routes
    end
  end
  resources :thumbnail, only: :show, constraints: {id: pid_constraint}

  resources :preservation_events, :only => :show, constraints: {id: /[1-9][0-9]*/}

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
