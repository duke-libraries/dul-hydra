require 'cancan'

class Ability

  include CanCan::Ability
  include Hydra::Ability
  include Hydra::PolicyAwareAbility

  def custom_permissions
    alias_action :datastreams, :datastream, :datastream_content, :to => :read
  end

end
