# Controller mixin required to inject Grouper group membership into user's ability via the session
module DulHydra::Grouper
  module Controller
    extend ActiveSupport::Concern

    included do
      prepend_before_filter :load_grouper_groups
    end

    protected

    def load_grouper_groups
      session[DulHydra.grouper_groups_session_key] ||= request.env.fetch(DulHydra.grouper_groups_env_key, [])
    end

  end
end
