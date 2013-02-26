DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  scope "bookmarks" do
    match "download_content" => "download#bookmarked_content"
  end

  Blacklight.add_routes(self)

  devise_for :users

  scope "catalog/:object_id" do
    resources :datastreams, :only => :show
    resources :preservation_events, :only => :index
    resources :audit_trail, :only => :index
  end
  
end
