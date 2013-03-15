module DulHydra::Scripts
  module AdminPolicies

    CONFIG_FILE = File.join(Rails.root, 'config', 'admin_policies.yml')

    def self.create_default_policies
      YAML.load_file(CONFIG_FILE).each do |attrs|
        begin
          apo = AdminPolicy.find(attrs[:pid])
        rescue ActiveFedora::ObjectNotFoundError
          begin
            apo = AdminPolicy.create(attrs)
          rescue ActiveFedora::UnknownAttributeError => e
            logger.error "AdminPolicy not created: #{e}"
          else
            logger.info "AdminPolicy #{apo.pid} created."
          end
        else
          logger.warn "AdminPolicy #{apo.pid} exists -- will not re-create."
        end
      end
    end

  end
end
