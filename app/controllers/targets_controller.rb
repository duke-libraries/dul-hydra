class TargetsController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::HasContentBehavior

  helper_method :upload_datastreams
  
  def upload_datastreams
    [ Ddr::Datastreams::CONTENT ]
  end
  
end
