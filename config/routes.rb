DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  Blacklight.add_routes(self)

  devise_for :users

  mount FcrepoAdmin::Engine => '/fcrepo', :as=> 'fcrepo_admin'

  scope "objects/:object_id" do
    get 'thumbnail' => 'thumbnail#show'
  end

  scope "catalog/:id" do
    get 'download' => 'downloads#show'
    get 'preservation_events' => 'preservation_events#index'
  end

  resources :export_sets do
    member do
      post 'archive'
      delete 'archive'
    end
  end
  
end
