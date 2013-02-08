DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  Blacklight.add_routes(self)
  HydraHead.add_routes(self)

  devise_for :users

  # DulHydra objects
  [:collections, :items, :components].each do |model|
    resources model
    match "/#{model}/:id/datastreams" => "#{model}#datastreams", :via => :get, :as => "#{model}_datastreams"
    match "/#{model}/:id/datastreams/:dsid" => "#{model}#datastream", :via => :get, :as => "#{model}_datastream"
    match "/#{model}/:id/datastreams/:dsid/content" => "#{model}#datastream_content", :via => :get, :as => "#{model}_datastream_content"
  end
  
end
