require 'dul_hydra'
require 'yaml'
require 'grouper-rest-client'

module DulHydra::Grouper
  class Client < Grouper::Rest::Client::Resource

    def initialize
      @@config ||= YAML.load_file("#{Rails.root}/config/grouper.yml")[Rails.env]
      super(@@config["url"], user: @@config["user"], password: @@config["password"])
    end

    # List of all grouper groups for the repository
    def self.repository_groups
      new.groups(DulHydra.grouper_groups_name_filter)
    end

    def self.repository_group_names
      repository_groups.collect { |g| g["name"] }
    end

    def self.user_groups(user)
      request_body = { 
        "WsRestGetGroupsRequest" => {
          "subjectLookups" => [{"subjectIdentifier" => subject_id(user)}]
        }
      }
      # Have to use :call b/c grouper-rest-client :subjects method doesn't support POST
      result = new.call("subjects", :post, request_body)["WsGetGroupsResults"]["results"].first
      # Have to manually filter results b/c Grouper WS version 1.5 does not support filter parameter
      if result && result["wsGroups"]
        result["wsGroups"].select { |g| g["name"] =~ /^#{DulHydra.grouper_groups_name_filter}/ }
      else
        []
      end
    end

    def self.user_group_names(user)
      user_groups(user).collect { |g| g["name"] }
    end
    
    def self.subject_id(user)
      user.username.split('@').first
    end

  end
end
