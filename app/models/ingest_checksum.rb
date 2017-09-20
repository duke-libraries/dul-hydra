class IngestChecksum

  attr_reader :checksum_filepath

  def initialize(checksum_filepath)
    @checksum_filepath = checksum_filepath
    @checksum_hash = {}
  end

  def checksum(filepath)
    checksums[filepath]
  end

  private

  def checksums
    if @checksum_hash.empty?
      begin
        File.open(checksum_filepath, 'r') do |file|
          file.each_line do |line|
            sum, path = line.split
            @checksum_hash[path] = sum
          end
        end
      end
    end
    @checksum_hash
  end

end
