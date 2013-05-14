DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  Blacklight.add_routes(self)

  devise_for :users

  mount FcrepoAdmin::Engine => '/', :as=> 'fcrepo_admin'

  scope "objects/:object_id" do
    get 'children' => 'children#index'
    get 'preservation_events' => 'preservation_events#index'
    get 'thumbnail' => 'thumbnail#show'
  end

  resources :export_sets do
    member do
      post 'archive'
      delete 'archive'
    end
  end
  
end
