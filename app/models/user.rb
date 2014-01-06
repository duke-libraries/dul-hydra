class User < ActiveRecord::Base

  include Hydra::User
  include Blacklight::User

  has_many :batches, :inverse_of => :user, :class_name => DulHydra::Batch::Models::Batch
  has_many :ingest_folders, :inverse_of => :user
  has_many :metadata_files, :inverse_of => :user
  has_many :export_sets, :dependent => :destroy

  delegate :can?, :cannot?, to: :ability
  delegate :can_create_model?, :can_create_models?, :can_create_models, to: :ability

  validates_uniqueness_of :username, :case_sensitive => false
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/

  devise :remote_user_authenticatable, :database_authenticatable, :registerable,
         :rememberable, :trackable, :validatable

#  attr_accessible :username, :email, :password, :password_confirmation, :remember_me

  attr_writer :group_service

  def group_service
    # This is a fallback -- see config/initializers/dul_hydra.rb,
    # which uses a Warden callback to set group_service on the
    # authenticated user.
    @group_service ||= DulHydra::Services::GroupService.new
  end

  def to_s
    user_key
  end

  def ability
    @ability ||= ::Ability.new(self)
  end

  def groups
    @groups ||= group_service.user_groups(self)
  end

  def member_of?(group)
    group ? self.groups.include?(group) : false
  end
  
  def superuser?
    member_of? group_service.superuser_group
  end

end
