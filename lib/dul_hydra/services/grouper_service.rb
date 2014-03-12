require 'dul_hydra'
require 'grouper-rest-client'

module DulHydra
  module Services
    class GrouperService

      class_attribute :config

      def self.configured?
        !config.nil?
      end

      # List of all grouper groups for the repository
      def self.repository_groups
        groups = []
        begin
          client do |c|
            g = c.groups(DulHydra.remote_groups_name_filter)
            groups = g if c.ok?
          end
        rescue DulHydra::Error
        end
        groups
      end

      def self.repository_group_names
        repository_groups.collect { |g| g["name"] }
      end

      def self.user_groups(user)
        groups = []
        begin
          client do |c|
            request_body = { 
              "WsRestGetGroupsRequest" => {
                "subjectLookups" => [{"subjectIdentifier" => subject_id(user)}]
              }
            }
            # Have to use :call b/c grouper-rest-client :subjects method doesn't support POST
            response = c.call("subjects", :post, request_body)
            if c.ok?
              result = response["WsGetGroupsResults"]["results"].first
              # Have to manually filter results b/c Grouper WS version 1.5 does not support filter parameter
              if result && result["wsGroups"]
                groups = result["wsGroups"].select { |g| g["name"] =~ /^#{DulHydra.remote_groups_name_filter}/ }
              end
            end
          end
        rescue StandardError => e
          logger.error e
        end
        groups
      end

      def self.user_group_names(user)
        user_groups(user).collect { |g| g["name"] }
      end
      
      def self.subject_id(user)
        user.user_key.split('@').first
      end

      private

      def self.client
        raise DulHydra::Error unless configured?
        yield Grouper::Rest::Client::Resource.new(config["url"], 
                                                  user: config["user"], 
                                                  password: config["password"],
                                                  timeout: config.fetch("timeout", 5).to_i
                                                  )
      end

    end
  end
end
