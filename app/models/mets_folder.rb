class METSFolder < ActiveRecord::Base

  include ActiveModel::Validations

  belongs_to :user, inverse_of: :ingest_folders

  validates_presence_of(:sub_path)

  def full_path
    File.join(base_path, sub_path)
  end

end
