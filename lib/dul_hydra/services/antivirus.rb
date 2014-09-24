require 'clamav'

module DulHydra
  module Services
    class Antivirus

      SOFTWARE = "ClamAV"

      class << self
        def scan(file)
          result = scan_one(DulHydra::Utils.file_path(file)) # raises ArgumentError
          raise DulHydra::VirusFoundError, result if result.has_virus?
          raise DulHydra::Error, "Antivirus error (#{result.version})" if result.error?
          Rails.logger.info result
          result
        rescue ArgumentError => e
          raise ArgumentError, "Can't run virus scan on blob (not a File or file path)"
        end

        def scan_one(path)
          loaded? ? reload! : load!
          raw_result = engine.scanfile path
          ScanResult.new raw_result, path
        end

        def load!
          load
          loaded!
        end

        def reload!
          # ClamAV is supposed to reload the database if changed (1 = successful, 0 = unnecessary)
          # but operation only succeeds when unneccesary and raises RuntimeError when the db needs
          # to be reloaded.
          (engine.reload == 1) && version(true)
        rescue RuntimeError
          load!
        end

        def version(reset = false)
          # Engine and database versions
          # E.g., ClamAV 0.98.3/19010/Tue May 20 21:46:01 2014
          @version = nil if reset
          @version ||= `sigtool --version`.strip
        end

        private

        def loaded!
          @loaded = true
        end

        def loaded?
          !@loaded.nil?
        end

        def load
          engine.loaddb
          version(true)
        end

        def engine
          ClamAV.instance
        end
      end

      class ScanResult
        attr_reader :raw, :file_path, :scanned_at, :version

        def initialize(raw, file_path, opts={})
          @raw = raw
          @file_path = file_path
          @scanned_at = opts.fetch(:scanned_at, Time.now.utc)
          @version = DulHydra::Services::Antivirus.version
        end

        def virus_found
          raw if raw.is_a? String
        end

        def has_virus?
          !virus_found.nil?
        end

        def status
          if has_virus?
            "FOUND #{virus_found}"
          elsif error?
            "ERROR"
          else
            "OK"
          end
        end

        def ok?
          !(has_virus? || error?)
        end

        def error?
          raw == 1
        end

        def to_s
          "Virus scan: #{status} - #{file_path} (#{version})"
        end
      end

    end
  end
end
