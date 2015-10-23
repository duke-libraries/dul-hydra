require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'

module DulHydra
  module Scripts
    class BatchFixityCheck

      warn "[DEPRECATION] `DulHydra::Scripts::BatchFixityCheck` is deprecated and will be removed." \
           " Use `DulHydra::Fixity.check` instead."

      # TODO migrate defaults to config
      DEFAULT_LIMIT = 1000
      DEFAULT_PERIOD = "60DAYS"

      attr_reader :limit, :log, :period, :report, :report_file, :summary, :executed

      def initialize(opts={})
        @limit = opts.fetch(:limit, DEFAULT_LIMIT).to_i
        @period = opts.fetch(:period, DEFAULT_PERIOD)
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
          result = obj.fixity_check
          outcome = result.success ? Ddr::Events::Event::SUCCESS : Ddr::Events::Event::FAILURE
          log_outcome(result, outcome)
          report_result(result) # pass obj so we have dsChecksumValid
          update_summary(result, outcome)
        end
      end

      def log_outcome(result, outcome)
        msg = "Fixity check outcome for #{result.pid} -- #{outcome.upcase}."
        result.success ? log.info(msg) : log.error(msg)
      end

      def write_report_header
        if report?
          report << ['PID', 'Datastream', 'dsVersionID', 'dsCreateDate', 'dsChecksumType', 'dsChecksum', 'dsChecksumValid']
        end
      end

      def report_result(result)
        if report?
          result.results.each do |dsid, profile|
            report << [result.pid,
                       dsid,
                       profile["dsVersionID"],
                       profile["dsCreateDate"].localtime,
                       profile["dsChecksumType"],
                       profile["dsChecksum"],
                       profile["dsChecksumValid"]
                      ]
          end
        end
      end

      def update_summary(result, outcome)
        summary[:objects][result.pid] = outcome
      end

      def objects_to_check
        log.info "Finding objects to check ..."
        rows = limit
        results = objects_never_checked(rows)
        rows -= results.size
        results += objects_last_checked_before_period(rows) if rows > 0
        log.info "#{results.size} matching objects found."
        ActiveFedora::SolrService.lazy_reify_solr_results results
      end

      def objects_last_checked_before_period(rows)
        q = "#{Ddr::Index::Fields::LAST_FIXITY_CHECK_ON}:[* TO NOW-#{period}]"
        ActiveFedora::SolrService.query(q, rows: rows, sort: "#{Ddr::Index::Fields::LAST_FIXITY_CHECK_ON} asc")
      end

      def objects_never_checked(rows)
        q = "-#{Ddr::Index::Fields::LAST_FIXITY_CHECK_ON}:[* TO *]"
        ActiveFedora::SolrService.query(q, rows: rows)
      end

    end
  end
end
