DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  Blacklight.add_routes(self)

  devise_for :users

  scope "catalog/:object_id" do
    get 'thumbnail' => 'thumbnail#show'
    resources :datastreams, :only => :show do
      member do
        get 'download'
      end
    end
    resources :preservation_events, :only => :index
    resources :audit_trail, :only => :index
  end
  
  resources :export_sets, :except => [:edit, :update]
  
end
