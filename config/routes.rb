DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  Blacklight.add_routes(self)

  devise_for :users

  mount FcrepoAdmin::Engine => '/fcrepo', :as=> 'fcrepo_admin'

  get 'download/:id' => 'downloads#show', :as => 'download'

  scope "objects/:object_id" do
    get 'metadata' => 'fcrepo_admin/download#show', defaults: {id: DulHydra::Datastreams::DESC_METADATA}
    get 'event_metadata' => 'fcrepo_admin/download#show', defaults: {id: DulHydra::Datastreams::EVENT_METADATA}
    get 'thumbnail' => 'thumbnail#show'
  end

  scope "catalog/:id" do
    get 'preservation_events' => 'preservation_events#index'
  end

  resources :export_sets do
    member do
      post 'archive'
      delete 'archive'
    end
  end
  
end
