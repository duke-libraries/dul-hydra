class User < ActiveRecord::Base

  include Blacklight::User
  include Ddr::Auth::User
  include Ddr::Batch::BatchUser

  has_many :ingest_folders, :inverse_of => :user
  has_many :metadata_files, :inverse_of => :user
  has_many :export_sets, :dependent => :destroy

  def aspace_username
    if m = /(.+)@duke\.edu\z/.match(user_key)
      m[1]
    end
  end

end
