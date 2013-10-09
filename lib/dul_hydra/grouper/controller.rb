# Controller mixin
module DulHydra::Grouper
  module Controller
    extend ActiveSupport::Concern

    included do
      before_filter :add_groups_to_session
    end

    protected

    def add_groups_to_session
      session[:grouper_groups] ||= env.fetch("isMemberOf", [])
    end

  end
end
