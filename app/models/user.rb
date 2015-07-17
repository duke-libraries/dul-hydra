class User < ActiveRecord::Base

  include Blacklight::User
  include Ddr::Auth::User

  has_many :batches, :inverse_of => :user, :class_name => DulHydra::Batch::Models::Batch
  has_many :ingest_folders, :inverse_of => :user
  has_many :metadata_files, :inverse_of => :user
  has_many :export_sets, :dependent => :destroy

end
