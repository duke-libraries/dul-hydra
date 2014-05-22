module DulHydra
  module Services
    class Antivirus

      class AntivirusError < DulHydra::Error; end
      class VirusFoundError < AntivirusError; end
      class AntivirusEngineError < AntivirusError; end

      class << self
        def scan(file)
          result = scan_one file
          raise VirusFoundError, result if result.has_virus?
          raise AntivirusEngineError, result.version if result.error?
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
          raise DulHydra::Error, "Antivirus is not installed." unless installed?
          load
        end

        def version
          # ClamAV sigtool may be installed on system,
          # but we require that clamav gem is installed.
          return unless installed?
          # Engine and database versions
          # E.g., ClamAV 0.98.3/19010/Tue May 20 21:46:01 2014
          `sigtool --version`.strip
        end

        def installed?
          @installed ||= begin
                           require 'clamav'
                         rescue LoadError
                           false
                         else
                           true
                         end
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
          loaded!
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

    end
  end
end
