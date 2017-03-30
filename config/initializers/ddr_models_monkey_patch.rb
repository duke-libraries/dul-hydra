module Ddr::Managers
  class TechnicalMetadataManager

    delegate :pid, to: :object

    def checksum_digest
      if content.external?
        Ddr::Datastreams::CHECKSUM_TYPE_SHA1
      else
        content.checksumType
      end
    end

    def checksum_value
      if content.external?
        FileDigest.sha1(pid, Ddr::Datastreams::CONTENT)
      else
        content.checksum
      end
    end

  end
end
