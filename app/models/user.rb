class User < ActiveRecord::Base

  has_many :batches, :inverse_of => :user
  has_many :export_sets, :dependent => :destroy
  delegate :can?, :cannot?, :to => :ability
  validates_uniqueness_of :username, :case_sensitive => false
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/

  # Connects this user object to Hydra behaviors. 
  include Hydra::User

  # Connects this user object to Blacklights Bookmarks and Folders. 
  include Blacklight::User

  # Overrides #groups instance method to integrate with Grouper
  include DulHydra::Grouper::User
  
  devise :remote_user_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :username, :email, :password, :password_confirmation, :remember_me

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account. 
  def to_s
    username
  end

  def ability(session = nil)
    @ability ||= Ability.new(self, session)
  end

end
