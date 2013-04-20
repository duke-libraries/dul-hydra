require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'
require 'json'

module DulHydra::Scripts
  class FixityCheck
    
    # TODO migrate defaults to config
    DEFAULT_LIMIT = 1000
    DEFAULT_PERIOD = "60DAYS"
    QUERY = "#{ActiveFedora::SolrService.solr_name(:last_fixity_check_on, :date)}:[* TO NOW-%s]"
    SORT = "#{ActiveFedora::SolrService.solr_name(:last_fixity_check_on, :date)} asc"

    attr_reader :limit, :dryrun, :log, :report, :query, :fixity_check_options, :mailto

    def initialize(opts={})
      @limit = opts.fetch(:limit, DEFAULT_LIMIT).to_i
      @query = QUERY % opts.fetch(:period, DEFAULT_PERIOD)
      @dryrun = opts.fetch(:dryrun, false)
      @mailto = opts[:mailto]
      @fixity_check_options = opts.fetch(:options, {}) # options to pass through to FixityCheck
    end

    def execute
      start
      check_objects
      finish
    end

    private

    def start
      start_log
      start_report
    end

    def finish
      finish_log
      finish_report
    end

    def start_log
      logconfig = Log4r::YamlConfigurator
      logconfig['HOME'] = Rails.root.to_s
      logconfig.load_yaml_file File.join(Rails.root, 'config', 'log4r_fixity_check.yml')
      @log = Log4r::Logger['fixity_check']
      log.info "Starting fixity check routine ..."
      log.info "DRY RUN -- No changes will be made to the repository." if dryrun
    end

    def finish_log
      log.info "Fixity check routine complete."
    end

    def start_report
      @report = CSV.open(File.join(Rails.root, "log", "fixity_check_report_#{Time.now.strftime('%F')}.csv"), 'wb')
      write_report_header
    end

    def finish_report
      report.close
      mail_report if mailto
    end

    def mail_report
      # mail report.path
    end

    def check_objects
      objects_to_check.each do |obj| 
        # next unless obj.is_a?(DulHydra::Models::HasPreservationEvents)
        event = check_object(obj)
        log_outcome(event)
        report_outcome(event)
      end
    end

    def write_report_header
      report << ['PID', 'Datastream', 'Outcome', 'OutcomeDate', 'dsVersionID', 'asOfDateTime', 'ChecksumType', 'Checksum']
    end

    def write_report_row(ds, event)
      outcome = ds["dsChecksumValid"] ? PreservationEvent::SUCCESS : PreservationEvent::FAILURE
      report << [event.for_object.pid, ds["dsID"], outcome, event.event_date_time, ds["dsVersionID"], ds["asOfDateTime"], ds["dsChecksumType"], ds["dsChecksum"]]
    end

    def check_object(obj)
      method = dryrun ? :validate_checksums : :validate_checksums!
      obj.send(method, fixity_check_options)
    end

    def log_outcome(event)
      msg = "Fixity check outcome for #{event.for_object.pid}: #{event.event_outcome}."
      event.success? ? log.info(msg) : log.error(msg)
    end

    def report_outcome(event)
      detail = JSON.parse(event.event_detail)
      detail[:datastreams].each { |ds| write_report_row(ds, event) }
    end

    def objects_to_check
      log.info "Querying index: #{query} (limit: #{limit}) ..."
      results = ActiveFedora::SolrService.query(query, :rows => limit, :sort => SORT)
      log.info "#{results.size} matching objects found."
      ActiveFedora::SolrService.reify_solr_results results
    end

  end
end
