# Common behavior for repository object controllers
module DulHydra
  module RepositoryController
    extend ActiveSupport::Concern

    include DulHydra::EventLogBehavior

    included do
      log_actions :create, :update
    end

  end
end
