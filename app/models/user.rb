class User < ActiveRecord::Base

  include Hydra::User
  include Blacklight::User

  has_many :batches, :inverse_of => :user, :class_name => DulHydra::Batch::Models::Batch
  has_many :ingest_folders, :inverse_of => :user
  has_many :metadata_files, :inverse_of => :user
  has_many :export_sets, :dependent => :destroy
  has_many :events, :inverse_of => :user

  has_and_belongs_to_many :roles

  delegate :can?, :cannot?, to: :ability

  validates_uniqueness_of :username, :case_sensitive => false
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/

  devise :remote_user_authenticatable, :database_authenticatable, :rememberable, :trackable, :validatable

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
  
  def authorized_to_act_as_superuser?
    member_of? group_service.superuser_group
  end

  def effective_roles
    @effective_roles ||= (roles | Role.where.not(groups: nil).reject { |r| (r.groups & groups).empty? })
  end

  def role_names
    effective_roles.map(&:name)
  end

  def role_abilities
    effective_roles.map(&:ability_params).compact
  end

  def has_role? role
    if role.is_a? Role
      effective_roles.include? role
    elsif role.is_a? String
      role_names.include? role
    else
      raise ArgumentError, "role must be a Role or a String"
    end
  end

end
