class DeletedFile < ActiveRecord::Base

  # Source constants
  FOXML          = "FOXML"
  F3_DS_EXTERNAL = "F3-DS-E"
  F3_DS_MANAGED  = "F3-DS-M"

  validates_presence_of :repo_id, :source

end
