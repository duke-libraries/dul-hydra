class User < ActiveRecord::Base

  include Hydra::User
  include Blacklight::User

  has_many :batches, :inverse_of => :user, :class_name => DulHydra::Batch::Models::Batch
  has_many :ingest_folders, :inverse_of => :user
  has_many :export_sets, :dependent => :destroy

  delegate :can?, :cannot?, :can_create_models?, to: :ability

  validates_uniqueness_of :username, :case_sensitive => false
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/

  devise :remote_user_authenticatable, :database_authenticatable, :registerable,
         :rememberable, :trackable, :validatable

  attr_accessible :username, :email, :password, :password_confirmation, :remember_me

  attr_writer :group_service

  def group_service
    @group_service ||= DulHydra::Services::GroupService.new
  end

  def to_s
    user_key
  end

  def ability
    @ability ||= ::Ability.new(self)
  end

  def groups
    @groups ||= group_service.groups(self)
  end

  def member_of?(group)
    group ? self.groups.include?(group) : false
  end

end
