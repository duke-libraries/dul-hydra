require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'

module DulHydra::Scripts
  class FixityCheck
    
    # TODO migrate defaults to config
    DEFAULT_LIMIT = 100
    DEFAULT_PERIOD = "6MONTHS"
    QUERY = "#{ActiveFedora::SolrService.solr_name(:last_fixity_check_on, :date)}:[* TO NOW-%s] AND (#{ActiveFedora::SolrService.solr_name(:active_fedora_model, :symbol)}:Component OR #{ActiveFedora::SolrService.solr_name(:active_fedora_model, :symbol)}:Target)"
    SORT = "#{ActiveFedora::SolrService.solr_name(:last_fixity_check_on, :date)} asc"

    attr_reader :limit, :period, :dryrun, :log, :report, :query

    def initialize(opts={})
      init_log
      @limit = opts.fetch(:limit, DEFAULT_LIMIT).to_i
      @period = opts.fetch(:period, DEFAULT_PERIOD)
      @query = QUERY % @period
      @dryrun = opts.fetch(:dryrun, false)
      @report = {success: [], failure: [], error: [], warn: []}
    end

    def execute
      log.info "Starting fixity check routine ..."      
      log.info "DRY RUN -- No changes will be made to the repository." if dryrun
      log.info "Querying index: #{query} (limit: #{limit}) ..."
      results = ActiveFedora::SolrService.query(query, :rows => limit, :sort => SORT)
      log.info "#{results.size} matching objects found."
      results.each do |r|
        doc = SolrDocument.new(r)
        unless doc.datastreams.has_key? DulHydra::Datastreams::CONTENT
          msg = "#{doc.id}: Object does not have a \"#{DulHydra::Datastreams::CONTENT}\" datastream, so will be skipped."
          log.warn msg
          report[:warn] << msg
          next
        end
        begin
          log.info "Retrieving #{doc.id} for fixity check ..."
          obj = ActiveFedora::Base.find(doc.id, :cast => true) 
          unless obj.is_a? DulHydra::Models::HasContent
            msg = "#{obj.pid}: Object type #{obj.class.to_s} does not implement DulHydra::Models::HasContent, so will be skipped."
            log.warn msg
            report[:warn] << msg
          end
          log.debug "Performing fixity check ..."
          if dryrun
            event = obj.validate_content_checksum
          else
            event = obj.validate_content_checksum!
          end
          msg = "Fixity check outcome: #{event.event_outcome}."
          if event.success?
            log.info msg
            report[:success] << obj.pid
          else
            log.error msg
            report[:failure] << obj.pid
          end
        rescue ActiveFedora::ObjectNotFoundError
          msg = "Object #{doc.id} not found."
          log.error msg
          report[:error] << msg
        end
      end
      log.info "Fixity check routine complete."
      return true
    end

    def validate_checksums
      get_objects.each do |obj| 
        unless obj.is_a? DulHydra::Models::HasContent
        event = validate_checksum obj
        report_event_outcome event
      end
    end

    private

    def init_log
      logconfig = Log4r::YamlConfigurator
      logconfig['HOME'] = Rails.root.to_s
      logconfig.load_yaml_file File.join(Rails.root, 'config', 'log4r_fixity_check.yml')
      @log = Log4r::Logger['fixity_check']
    end

    def validate_checksum(obj)
      dryrun ? obj.validate_content_checksum : obj.validate_content_checksum!
    end

    def report_event_outcome(event)
      msg = "Fixity check outcome for #{event.for_object.pid}: #{event.event_outcome}."
      if event.success?
        log.info msg
        report[:success] << event.for_object.pid
      else
        log.error msg
        report[:failure] << event.for_object.pid
      end      
    end

    def get_objects
      log.info "Querying index: #{query} (limit: #{limit}) ..."
      results = ActiveFedora::SolrService.query(query, :rows => limit, :sort => SORT)
      log.info "#{results.size} matching objects found."
      ActiveFedora::SolrService.reify_solr_results results
    end

  end
end
