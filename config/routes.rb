require 'resque/server'

DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  blacklight_for :catalog

  scope 'superuser', as: 'superuser' do
    get 'sign_in', to: 'superuser#create'
    get 'sign_out', to: 'superuser#destroy'
  end

  get 'id/*permanent_id', to: 'permanent_ids#show'

  namespace :admin do
    get 'dashboard', to: 'dashboard#show'
    get 'reports/:type', to: 'reports#show', as: 'report', constraints: {format: 'csv'}

    if defined?(DulHydra::ResqueAdmin)
      constraints DulHydra::ResqueAdmin do
        mount Resque::Server, at: '/queues'
      end
    end
  end

  # Common routes for Ddr::Models::Base descendants
  def model_routes
    get   'admin_metadata'
    patch 'admin_metadata'

    get   'events'
    get   'events/:event_id', to: :event

    get   'roles'
    patch 'roles'

    get   'versions'
  end

  # Common routes for content-bearing objects
  def content_routes
    get   'upload'
    patch 'upload'
  end

  # Common routes for publication
  def publication_routes
    get 'publish'
    get 'unpublish'
  end

  resources :collections, only: [:new, :create, :show, :edit, :update] do
    member do
      model_routes
      publication_routes
      get 'items'
      get 'attachments'
      get 'targets'
      get 'report'
    end
  end

  resources :items, only: [:new, :create, :show, :edit, :update] do
    member do
      model_routes
      publication_routes
      get 'components'
    end
  end

  resources :components, only: [:new, :create, :show, :edit, :update] do
    member do
      model_routes
      publication_routes
      content_routes
    end
  end

  resources :attachments, only: [:new, :create, :show, :edit, :update] do
    member do
      model_routes
      content_routes
    end
  end

  resources :targets, only: [:show, :edit, :update] do
    member do
      model_routes
      content_routes
    end
  end

  resources :thumbnail, only: :show

  # Downloads
  get 'download/:id(/:file)' => 'downloads#show', as: 'download'

  resources :export_sets do
    member do
      get    'archive', as: 'download'
      patch  'archive'
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
    resources :batch_object_files, :only => :index
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

  resources :mets_folders, :only => [:new, :create, :show] do
    member do
      get 'procezz'
    end
  end

  get '/help', to: redirect(DulHydra.help_url)

end
