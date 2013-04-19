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

    attr_reader :limit, :period, :dryrun, :log, :report, :query, :options, :mailto

    def initialize(opts={})
      @limit = opts.fetch(:limit, DEFAULT_LIMIT).to_i
      @query = QUERY % opts.fetch(:period, DEFAULT_PERIOD)
      @dryrun = opts.fetch(:dryrun, false)
      @mailto = opts[:mailto]
      @options = opts.fetch(:options, {}) # options to pass through to FixityCheck
    end

    def execute
      init_log
      init_report
      log.info "Starting fixity check routine ..."      
      log.info "DRY RUN -- No changes will be made to the repository." if dryrun
      check_objects
      log.info "Fixity check routine complete."
      report.close
      mail_report if mailto
    end

    def mail_report
      # mail report.path
    end

    def check_objects
      get_objects.each { |obj| report_outcome(check_object(obj)) }
    end

    private

    def init_log
      logconfig = Log4r::YamlConfigurator
      logconfig['HOME'] = Rails.root.to_s
      logconfig.load_yaml_file File.join(Rails.root, 'config', 'log4r_fixity_check.yml')
      @log = Log4r::Logger['fixity_check']
    end

    def init_report
      @report = CSV.open(File.join(Rails.root, "log", "fixity_check_report_#{Time.now.strftime('%F')}.csv"), 'wb')
      write_report_header
    end

    def write_report_header
      report << ['PID', 'Datastream', 'Outcome', 'OutcomeDate', 'dsVersionID', 'asOfDateTime', 'ChecksumType', 'Checksum']
    end

    def write_report_row(ds, event)
      outcome = ds["dsChecksumValid"] ? PreservationEvent::SUCCESS : PreservationEvent::FAILURE
      report << [event.for_object.pid, ds["dsID"], outcome, event.event_date_time, ds["dsVersionID"], ds["asOfDateTime"], ds["dsChecksumType"], ds["dsChecksum"]]
    end

    def write_report_rows(event)
      detail = JSON.parse(event.event_detail)
      detail[:datastreams].each { |ds| write_report_row(ds, event) }
    end

    def check_object(obj)
      fixity_check = DulHydra::FixityCheck.new(obj, options)
      dryrun ? fixity_check.execute : fixity_check.execute!
    end

    def report_outcome(event)
      msg = "Fixity check outcome for #{event.for_object.pid}: #{event.event_outcome}."
      event.success? ? log.info msg : log.error msg
      write_report_rows(event)
    end

    def get_objects
      log.info "Querying index: #{query} (limit: #{limit}) ..."
      results = ActiveFedora::SolrService.query(query, :rows => limit, :sort => SORT)
      log.info "#{results.size} matching objects found."
      ActiveFedora::SolrService.reify_solr_results results
    end

  end
end
