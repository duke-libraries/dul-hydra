class User < ActiveRecord::Base

  include Blacklight::User
  include Ddr::Auth::User
  include Ddr::Batch::BatchUser

  has_many :ingest_folders, inverse_of: :user
  has_many :metadata_files, inverse_of: :user
  has_many :mets_folders, inverse_of: :user
  has_many :export_sets, dependent: :destroy

end
