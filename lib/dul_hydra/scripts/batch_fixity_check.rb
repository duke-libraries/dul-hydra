require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'
require 'json'

module DulHydra::Scripts
  class BatchFixityCheck
    
    # TODO migrate defaults to config
    DEFAULT_LIMIT = 1000
    DEFAULT_PERIOD = "60DAYS"
    QUERY = "#{ActiveFedora::SolrService.solr_name(:last_fixity_check_on, :date)}:[* TO NOW-%s]"
    SORT = "#{ActiveFedora::SolrService.solr_name(:last_fixity_check_on, :date)} asc"

    attr_reader :limit, :dryrun, :log, :query, :report, :summary, :executed

    def initialize(opts={})
      @limit = opts.fetch(:limit, DEFAULT_LIMIT).to_i
      @query = QUERY % opts.fetch(:period, DEFAULT_PERIOD)
      @dryrun = opts.fetch(:dryrun, false)
      @summary = {total: 0, success: 0, failure: 0}
      @executed = false
    end

    def execute
      raise "Batch fixity check has been executed -- call #report or #summary to get results." if executed
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
      executed = true
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
      @report = CSV.open(File.join(Rails.root, "log", "batch_fixity_check_#{Time.now.strftime('%F')}.csv"), "wb")
      write_report_header
    end

    def finish_report
      report.close
    end

    def check_objects
      objects_to_check.each do |obj| 
        event = check_object(obj)
        log_outcome(event)
        report_outcome(event)
        update_summary(event)
      end
    end

    def check_object(obj)
      dryrun ? obj.fixity_check : obj.fixity_check!
    end

    def log_outcome(event)
      msg = "Fixity check outcome for #{event.for_object.pid}: #{event.event_outcome}."
      event.success? ? log.info(msg) : log.error(msg)
    end

    def write_report_header
      report << ['PID', 'Datastream', 'dsVersionID', 'dsCreateDate', 'dsChecksumType', 'dsChecksum', 'dsChecksumValid']
    end

    def report_outcome(event)
      event.fixity_check_detail.each do |dsid, dsProfile|
        report << [event.for_object.pid,
                   dsid,
                   dsProfile["dsVersionID"],
                   dsProfile["dsCreateDate"],
                   dsProfile["dsChecksumType"],
                   dsProfile["dsChecksum"],
                   dsProfile["dsChecksumValid"]
                   ]
      end
    end

    def update_summary(event)
      summary[:total] += 1
      if event.success?
        summary[:success] += 1
      else
        summary[:failure] += 1
      end
    end

    def objects_to_check
      log.info "Querying index: #{query} (limit: #{limit}) ..."
      results = ActiveFedora::SolrService.query(query, :rows => limit, :sort => SORT)
      log.info "#{results.size} matching objects found."
      ActiveFedora::SolrService.reify_solr_results results
    end

  end
end
