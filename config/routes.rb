require 'resque/server'

DulHydra::Application.routes.draw do

  root :to => "catalog#index"
  Blacklight.add_routes(self)

  get 'superuser' => 'superuser#toggle'

  get 'id/*permanent_id' => 'permanent_ids#show'

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

  def content_routes
    get 'upload'
    patch 'upload'
  end

  def event_routes
    get 'events'
    get 'events/:event_id' => :event
  end

  def roles_routes
    get 'roles'
    patch 'roles'
  end

  def amd_routes
    get 'admin_metadata'
    patch 'admin_metadata'
  end

  def repository_routes
    event_routes
    roles_routes
    amd_routes
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
    get 'items'
    get 'attachments'
    get 'targets'
    get 'report'
    get 'reports'
  end
  repository_resource :items do
    get 'components'
  end
  repository_content_resource :components
  repository_content_resource :attachments
  repository_content_resource :targets
  resources :thumbnail, only: :show, constraints: {id: pid_constraint}

  # Downloads
  get 'download/:id(/:datastream_id)' => 'downloads#show', :constraints => {id: pid_constraint}, as: 'download'

  resources :export_sets do
    member do
      get 'archive', as: 'download'
      patch 'archive'
      delete 'archive'
    end
  end

  resources :batches, :only => [:index, :show, :destroy] do
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

  get '/help', to: redirect(DulHydra.help_url)

end
