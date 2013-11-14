DulHydra::Application.routes.draw do

  # http://railsadventures.wordpress.com/2012/10/07/routing-only-ajax-requests-in-ror/
  class XhrRequestConstraint
    def matches?(request)
      request.xhr?
    end
  end

  PID_CONSTRAINT = { id: /[a-zA-Z0-9\-_]+:[a-zA-Z0-9\-_]+/ }

  root :to => "catalog#index"

  Blacklight.add_routes(self)

  devise_for :users

  mount FcrepoAdmin::Engine => '/fcrepo', as: 'fcrepo_admin'

  resources :objects, only: [:show], constraints: PID_CONSTRAINT do
    member do
      get 'collection_info', constraints: XhrRequestConstraint
      get 'download' => 'downloads#show'
      get 'preservation_events', constraints: XhrRequestConstraint
      get 'thumbnail' => 'thumbnail#show'
      get 'datastreams/:datastream_id' => 'downloads#show', as: 'download_datastream'
    end
  end

  # hydra-editor for descriptive metadata
  scope '/objects/:id/descriptive_metadata', constraints: PID_CONSTRAINT, as: 'record' do
    get '/' => redirect {|params, req| "/objects/#{CGI::unescape(params[:id])}?tab=descriptive_metadata" }
    get 'edit' => 'objects#edit'
    put '/' => 'objects#update'
  end

  scope '/objects/:id/permissions', constraints: PID_CONSTRAINT, as: 'permissions' do
    get '/' => redirect {|params, req| "/objects/#{CGI::unescape(params[:id])}?tab=permissions" }
    get 'edit' => 'permissions#edit'
    put '/' => 'permissions#update'
  end

  resources :preservation_events, :only => :show, constraints: { id: /[1-9][0-9]*/ }

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
    resources :batch_objects do
      resources :batch_object_datastreams
      resources :batch_object_relationships
    end
  end

  resources :admin_policies, :only => [:edit, :update], constraints: PID_CONSTRAINT
  
end
