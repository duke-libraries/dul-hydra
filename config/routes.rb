DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  Blacklight.add_routes(self)

  devise_for :users

  scope "catalog/:object_id" do
    resources :datastreams, :only => :show
    get 'thumbnail' => 'datastreams#thumbnail'
    resources :preservation_events, :only => :index
    resources :audit_trail, :only => :index
  end
  
  resources :export_sets
  
end
