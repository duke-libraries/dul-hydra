module DulHydra
  # Base class for custom exceptions
  class Error < StandardError; end
  
  # Invalid checksum
  class ChecksumInvalid < Error; end

  # Virus found
  class VirusFoundError < Error; end
end
