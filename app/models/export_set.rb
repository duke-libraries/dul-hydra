class ExportSet < ActiveRecord::Base
  belongs_to :user
  has_attached_file :archive
  attr_accessible :archive, :pids
  serialize :pids
end