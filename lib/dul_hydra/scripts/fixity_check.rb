require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'

module DulHydra::Scripts
  module FixityCheck
    
    # TODO migrate defaults to config
    DEFAULT_LIMIT = 100
    DEFAULT_PERIOD = "6MONTHS"
    QUERY = "last_fixity_check_on_dt:[* TO NOW-%s] AND (active_fedora_model_s:Component OR active_fedora_model_s:Target)"
    SORT = "last_fixity_check_on_dt asc"

    def self.execute(opts={})
      # configure logging
      logconfig = Log4r::YamlConfigurator
      logconfig['HOME'] = Rails.root.to_s
      logconfig.load_yaml_file File.join(Rails.root, 'config', 'log4r_fixity_check.yml')
      log = Log4r::Logger['fixity_check']
      log.info "Starting fixity check routine ..."
      
      # options
      limit = opts.fetch(:limit, DEFAULT_LIMIT).to_i
      period = opts.fetch(:period, DEFAULT_PERIOD)
      dryrun = opts.fetch(:dryrun, false)
      
      if dryrun
        log.info "DRY RUN -- No changes will be made to the repository."
      end
      query = QUERY % period
      log.info "Querying index: #{query} (limit: #{limit}) ..."
      result = ActiveFedora::SolrService.query(query, :rows => limit, :sort => SORT)
      log.info "#{result.size} matching objects found."
      result.each do |r|
        doc = SolrDocument.new(r)
        unless doc.datastreams.has_key? DulHydra::Datastreams::CONTENT
          log.warn "#{doc.id} does not have a \"#{DulHydra::Datastreams::CONTENT}\" datastream, so will be skipped."
          next
        end
        begin
          log.info "Retrieving #{doc.id} for fixity check ..."
          obj = ActiveFedora::Base.find(doc.id, :cast => true) # need :cast => true ?
          log.debug "Performing fixity check ..."
          if dryrun
            event = obj.validate_content_checksum
          else
            event = obj.validate_content_checksum!
          end
          msg = "Fixity check outcome: #{event.event_outcome}."
          if event.success?
            log.info msg
          else
            log.error msg
          end
        rescue ActiveFedora::ObjectNotFoundError
          log.error "Object #{doc.id} not found."
        end
      end
      log.info "Fixity check routine complete."
      return true
    end

  end
end
