DulHydra::Application.routes.draw do

  root :to => "catalog#index"

  Blacklight.add_routes(self)
  HydraHead.add_routes(self)

  devise_for :users

  # DulHydra objects
  [:collections, :items, :components].each do |model|
    resources model
    match "/#{model}/:id/datastreams" => "#{model}#datastreams", :via => :get
    match "/#{model}/:id/datastreams/:dsid" => "#{model}#datastream", :via => :get
    match "/#{model}/:id/datastreams/:dsid/content" => "#{model}#datastream_content", :via => :get
  end
  
end
