require 'clamav'

module DulHydra
  module Services
    class Antivirus

      SOFTWARE = "ClamAV"

      class << self
        def scan(file)
          result = scan_one file
          raise DulHydra::VirusFoundError, result if result.has_virus?
          raise DulHydra::Error, "Antivirus error (#{result.version})" if result.error?
          logger.info result
          result
        end

        def scan_one(file)
          load! unless loaded?
          path = get_file_path file
          raw_result = engine.scanfile path
          ScanResult.new raw_result, path
        end

        def load!
          load
          loaded!
        end

        def version
          # Engine and database versions
          # E.g., ClamAV 0.98.3/19010/Tue May 20 21:46:01 2014
          `sigtool --version`.strip
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
        end

        def get_file_path(file)
          path = if file.is_a? String
                   file
                 elsif file.respond_to? :path
                   file.path
                 else
                   raise TypeError, "`file' argument must be a file or file path: #{file.inspect}"
                 end
          File.absolute_path path
        end

        def engine
          ClamAV.instance
        end
      end

      class ScanResult
        attr_reader :raw, :file, :scanned_at, :version

        def initialize(raw, file, opts={})
          @raw = raw
          @file = file
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
          "Virus scan: #{status} - #{file} (#{version})"
        end
      end

    end
  end
end
