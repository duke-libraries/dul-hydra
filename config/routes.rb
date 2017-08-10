require 'resque/server'

DulHydra::Application.routes.draw do

  root :to => "catalog#index"
  Blacklight.add_routes(self)

  scope 'superuser', as: 'superuser' do
    get 'sign_in', to: 'superuser#create'
    get 'sign_out', to: 'superuser#destroy'
  end

  get 'id/*permanent_id', to: 'permanent_ids#show'

  def pid_constraint
    /[a-zA-Z0-9\-_]+:[a-zA-Z0-9\-_]+/
  end

  namespace :admin do
    if defined?(DulHydra::ResqueAdmin)
      constraints DulHydra::ResqueAdmin do
        mount Resque::Server, at: '/queues'
      end
    end
  end

  def content_routes
    get 'upload'
    patch 'upload'
    get 'versions'
  end

  def event_routes
    get 'events'
    get 'events/:event_id', action: :event
  end

  def publication_routes
    get 'publish'
    get 'unpublish'
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
    get 'duracloud'
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
    publication_routes
    get 'items'
    get 'attachments'
    get 'targets'
    get 'export'
    post 'export'
    get 'aspace'
    post 'aspace'
  end
  repository_resource :items do
    publication_routes
    get 'components'
  end
  repository_resource :components do
    content_routes
    publication_routes
    get 'stream'
    get 'captions'
  end
  repository_content_resource :attachments
  repository_content_resource :targets
  resources :thumbnail, only: :show, constraints: {id: pid_constraint}

  # Downloads
  get 'download/:id(/:datastream_id)' => 'downloads#show', :constraints => {id: pid_constraint}, as: 'download'

  resources :batches, :only => [:index, :show, :destroy] do
    member do
      get 'procezz'
      get 'validate'
    end
  end

  get 'my_batches' => 'batches#index', filter: 'current_user'

  resources :batch_objects, :only => :show do
    resources :batch_object_datastreams, :only => :index
    resources :batch_object_relationships, :only => :index
  end

  resources :datastream_uploads, only: [ :new, :create, :show ]

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

  resources :nested_folder_ingests, :only => [:new, :create, :show]

  resources :standard_ingests, :only => [:new, :create, :show]

  get '/help', to: redirect(DulHydra.help_url)

end
