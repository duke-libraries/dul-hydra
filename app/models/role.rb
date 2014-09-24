class Role < ActiveRecord::Base

  MODELS = %w( Attachment Collection Component ExportSet Item MetadataFile Queue Role Target )
  ABILITIES = %w( create download manage )
  NIL_ATTRS = %w( model ability )

  validates_presence_of :name
  validates :model, inclusion: { in: MODELS }, allow_nil: true
  validates_presence_of :ability, unless: "model.nil?", message: "can't be blank if Model is selected"
  validates :ability, inclusion: { in: ABILITIES }, allow_nil: true
  validate :groups_must_be_array_or_nil

  serialize :groups

  has_and_belongs_to_many :users

  before_validation :nil_if_blank, :normalize_groups

  def to_s
    name
  end

  def inspect
    "#<Role: \"%s\" %s>" % [name, ability_params]
  end

  def ability_class
    model ? model.constantize : :all
  end

  def ability_params
    [ability.to_sym, ability_class] if ability
  end

  def groups_string
    groups.join(", ") if groups
  end

  def groups_text
    groups.join("\n") if groups
  end

  def users_string
    users.map(&:to_s).join(", ")
  end

  def model_display
    model || (ability && "(all)") || "--"
  end

  def ability_display
    ability || "--"
  end

  protected

  def nil_if_blank
    NIL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
  end

  def normalize_groups
    self.groups = groups.split(/\r?\n/) if groups.is_a?(String)
  end

  def groups_must_be_array_or_nil
    errors.add(:groups, "must be an array") unless groups.is_a?(Array) || groups.nil?
  end

end
