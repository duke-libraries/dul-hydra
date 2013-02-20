DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  Blacklight.add_routes(self)

  devise_for :users

  scope "catalog/:object_id" do
    resources :datastreams, :only => :show
    resources :preservation_events, :only => :index
  end
  
end
