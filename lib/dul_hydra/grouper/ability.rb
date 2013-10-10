# Mixin to extend Ability class for Grouper group support

require 'dul_hydra'

module DulHydra::Grouper
  module Ability

    def user_groups
      @user_groups ||= super + grouper_groups
    end

    def grouper_groups
      if session && session[DulHydra.grouper_groups_session_key]
        session[DulHydra.grouper_groups_session_key]
      else
        []
      end
    end

  end
end
