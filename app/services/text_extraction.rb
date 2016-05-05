class TextExtraction
  class << self
  # @param file [ActiveFedora::File]
  # @return [String] the extracted text
    def call(file)
      cmd = tika_command + ["-t", "-eUTF8", "-"]
      IO.popen(cmd, "r+b") do |io|
        file.stream.each { |chunk| io.write(chunk) }
        io.close_write
        bintext = io.read
        bintext.force_encoding(Encoding::UTF_8)
      end
    end

    def software
      @software ||= `#{tika_command_line} -V`.strip
    end

    def tika_path
      File.join(Rails.root, 'contrib', 'tika', 'tika-app.jar')
    end

    def tika_command
      [ "java", "-jar", tika_path ]
    end

    def tika_command_line
      tika_command.join(' ')
    end
  end
end
