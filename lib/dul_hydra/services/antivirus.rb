require 'clamav'

module DulHydra
  module Services
    class Antivirus

      class AntivirusError < DulHydra::Error; end
      class VirusFoundError < AntivirusError; end
      class AntivirusEngineError < AntivirusError; end

      class ScanResult

        attr_reader :raw, :file, :scanned_at, :version

        def initialize(raw, file, opts={})
          @raw = raw
          @file = file
          @scanned_at = opts.fetch(:scanned_at, DateTime.now)
          @version = opts.fetch(:version, DulHydra::Services::Antivirus.version)
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
          else
            "OK"
          end
        end

        def error?
          raw == 1
        end

        def to_s
          "Virus scan: #{status} - #{file} (#{version})"
        end

      end

      class << self

        def init
          engine.loaddb
        end

        def scan(file)
          result = scan_one file
          if result.has_virus?
            raise VirusFoundError, result
          end
          raise AntivirusEngineError, result.version if result.error?
          logger.info result
          result
        end

        def version
          # Engine and database versions
          # E.g., ClamAV 0.98.3/19010/Tue May 20 21:46:01 2014
          `sigtool --version`.strip
        end

        def reload
          # Reload virus database if changed
          #   1 - reload successful
          #   0 - reload unnecessary        
          engine.reload == 1
        end

        def scan_one(file)
          path = get_file_path file
          raw_result = engine.scanfile path
          ScanResult.new raw_result, path
        end

        private

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

    end
  end
end

DulHydra::Services::Antivirus.init
