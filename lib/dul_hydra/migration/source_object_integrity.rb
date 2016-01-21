module DulHydra::Migration
  class SourceObjectIntegrity

    attr_reader :source

    def initialize(source)
      @source = source
    end

    def verify
      source.datastreams.each do |dsid, ds|
        unless ds.dsChecksumValid
          raise FedoraMigrate::Errors::MigrationError, "Source #{source.pid} #{dsid} has invalid checksum"
        end
      end
    end

  end
end
