DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  Blacklight.add_routes(self)

  devise_for :users

  mount FcrepoAdmin::Engine => '/', :as=> 'fcrepo_admin'

  scope "objects/:object_id" do
    get 'thumbnail' => 'thumbnail#show'
  end

  scope 'objects/:id', :module => 'fcrepo_admin/objects' do
    get 'preservation_events'
  end
  
  resources :export_sets do
    member do
      post 'archive'
      delete 'archive'
    end
  end
  
end
