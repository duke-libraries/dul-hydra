require 'stringio'

module DulHydra
  module Datastreams
    class FileContentDatastream < ActiveFedora::Datastream
    
      DEFAULT_FILE_EXTENSION = "bin"
      BUFSIZE = 8192

      # Write datastream content to open file
      def write_content(file)
        StringIO.open(self.content, 'rb') do |strio|
          file.write(strio.read(BUFSIZE)) until strio.eof?
        end
      end

    end
  end
end
