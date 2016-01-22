# require 'equivalent-xml'

module DulHydra::Migration
  class TargetObjectIntegrity

    attr_reader :source, :target

    def initialize(source, target)
      @source = source
      @target = target
    end

    def verify
      source.datastreams.each do |dsid, datastream|
        if [ 'content', 'thumbnail', 'fits', 'extractedText' ].include?(dsid)
          verify_existence(dsid)
          if dsid == 'fits'
            verify_equivalence(dsid, datastream)
          else
            verify_checksum(dsid, datastream)
          end
        end
      end
    end

    private

    def verify_existence(dsid)
      unless target.attached_files[dsid]
        raise FedoraMigrate::Errors::MigrationError, "Failed to migrate #{source.pid} #{dsid}"
      end
    end

    def verify_checksum(dsid, datastream)
      target_checksum = target.attached_files[dsid].checksum
      unless target_checksum.value == datastream.checksum
        raise FedoraMigrate::Errors::MigrationError,
              "Checksum mismatch: #{dsid} #{source.pid} #{datastream.checksumType} #{datastream.checksum} #{target.id} #{target_checksum.algorithm} #{target_checksum.value}"
      end
    end

    def verify_equivalence(dsid, datastream)
      source_xml_doc = Nokogiri::XML(datastream.content)
      target_xml_doc = Nokogiri::XML(target.attached_files[dsid].content)
      unless EquivalentXml.equivalent?(target_xml_doc, source_xml_doc)
        raise FedoraMigrate::Errors::MigrationError, "Equivalence mismatch: fits #{source.pid} #{target.id}"
      end
    end

  end
end
