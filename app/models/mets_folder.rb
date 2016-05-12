class METSFolder < ActiveRecord::Base

  include ActiveModel::Validations

  belongs_to :user, inverse_of: :mets_folders

  validates_presence_of(:sub_path)

  validate :path_presence_and_readability, if: :sub_path

  def full_path
    File.join(base_path, sub_path)
  end

  def path_presence_and_readability
    unless Dir.exist?(full_path) && File.readable?(full_path)
      errors.add(:sub_path, "#{sub_path} not found, is not a directory, or is not readable")
    end
  end

end
