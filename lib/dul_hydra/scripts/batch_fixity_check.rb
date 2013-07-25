require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'

module DulHydra::Scripts
  class BatchFixityCheck
    
    # TODO migrate defaults to config
    DEFAULT_LIMIT = 1000
    DEFAULT_PERIOD = "60DAYS"
    QUERY = "#{DulHydra::IndexFields::LAST_FIXITY_CHECK_ON}:[* TO NOW-%s]"
    SORT = "#{DulHydra::IndexFields::LAST_FIXITY_CHECK_ON} asc"

    attr_reader :limit, :dryrun, :log, :query, :report, :report_file, :summary, :executed

    def initialize(opts={})
      @limit = opts.fetch(:limit, DEFAULT_LIMIT).to_i
      @query = QUERY % opts.fetch(:period, DEFAULT_PERIOD)
      @dryrun = opts.fetch(:dryrun, false)
      @summary = {objects: {}, at: nil}
      @report_file = opts[:report]
    end

    def execute
      raise "Batch fixity check has been executed -- call #report or #summary to get results." if summary[:at]
      start
      check_objects
      finish
    end

    def total
      summary[:objects].size
    end

    def outcome_counts
      outcomes.inject(Hash.new(0)) { |k, v| k[v] += 1; k }
    end

    def outcomes
      summary[:objects].values
    end

    def pids
      summary[:objects].keys
    end

    def report?
      !report.nil?
    end

    private

    def start
      summary[:at] = Time.now
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
      @report = CSV.open(report_file, "wb") rescue nil
      write_report_header
    end

    def finish_report
      report.close if report?
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
      msg = "Fixity check outcome for #{event.for_object.pid} -- #{event.event_outcome.upcase}."
      event.success? ? log.info(msg) : log.error(msg)
    end

    def write_report_header
      if report?
        report << ['PID', 'Datastream', 'dsVersionID', 'dsCreateDate', 'dsChecksumType', 'dsChecksum', 'dsChecksumValid']
      end
    end

    def report_outcome(event)
      if report?
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
    end

    def update_summary(event)
      summary[:objects][event.for_object.pid] = event.event_outcome
    end

    def objects_to_check
      log.info "Querying index: #{query} (limit: #{limit}) ..."
      results = ActiveFedora::SolrService.query(query, :rows => limit, :sort => SORT)
      log.info "#{results.size} matching objects found."
      ActiveFedora::SolrService.lazy_reify_solr_results results
    end

  end
end
