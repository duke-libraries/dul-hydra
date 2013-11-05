module DulHydra::Batch::Models

  class IngestFolder < ActiveRecord::Base
  
    attr_accessible :dirpath, :username, :admin_policy_pid, :collection_pid
  
  end

end