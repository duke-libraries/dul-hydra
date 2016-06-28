module DulHydra
  # Base class for custom DulHydra exceptions
  class Error < StandardError; end

  # Error related to batch operation
  class BatchError < Error; end

  class FileNotFound < Error; end
end
