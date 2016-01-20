module DulHydra::Jobs
  class ConvertChecksums

    @queue = :migration

    def self.perform(pid)
      obj = ActiveFedora::Base.find(pid)
      obj.datastreams.each do |dsid, ds|
        next unless ds.has_content?
        next if ds.checksumType == "SHA-1"
        unless ds.dsChecksumValid
          raise Ddr::Models::ChecksumInvalid, "#{obj.internal_uri}/datastreams/#{dsid}"
        end
        ds.checksumType = "SHA-1"
      end
      obj.save!
    end

  end
end
