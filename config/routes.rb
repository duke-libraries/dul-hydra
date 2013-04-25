DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  Blacklight.add_routes(self)

  devise_for :users

  mount FcrepoAdmin::Engine => '/admin', :as=> 'fcrepo_admin'

  scope "catalog/:object_id" do
    get 'thumbnail' => 'thumbnail#show'
    resources :datastreams, :only => :show do
      member do
        get 'download'
      end
    end
    resources :preservation_events, :only => :index
    resources :audit_trail, :only => :index
    resources :targets, :only => :index
    resources :children, :only => :index
  end
  
  resources :export_sets do
    member do
      post 'archive'
      delete 'archive'
    end
  end
  
end
