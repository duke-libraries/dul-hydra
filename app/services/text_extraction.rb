class TextExtraction
  class Error < DulHydra::Error; end
  class NoTextError < Error; end
  class EncryptedDocumentError < Error; end
  class CommandError < Error; end

  class << self
  # @param file [ActiveFedora::File]
  # @return [String] the extracted text
    def call(file)
      output = run_tika(file)
      handle_result(output, $?)
    end

    def software
      @software ||= `#{tika_command_line} -V`.strip
    end

    def tika_path
      File.join(Rails.root, 'contrib', 'tika', 'tika-app.jar')
    end

    private

    def tika_command
      [ "java", "-jar", tika_path ]
    end

    def tika_command_line
      tika_command.join(' ')
    end

    def tika_text_command
      @tika_text_command ||= tika_command + ["-t", "-eUTF8", "-"]
    end

    def handle_result(output, status)
      status.success? ? handle_success(output) : handle_error(output)
    end

    def handle_success(output)
      no_text?(output) ? no_text! : output
    end

    def handle_error(error)
      if encrypted?(error)
        encrypted!
      else
        raise CommandError, error
      end
    end

    def run_tika(file)
      IO.popen(tika_text_command, "r+b", err: [:child, :out]) do |io|
        file.stream.each { |chunk| io.write(chunk) }
        io.close_write
        output = io.read
        output.force_encoding(Encoding::UTF_8)
      end
    end

    def no_text!
      raise NoTextError,
            "Unable to extract text or file contains no text."
    end

    def encrypted!
      raise EncryptedDocumentError,
            "Unable to extract text from encrypted document."
    end

    def no_text?(output)
      output =~ /\A\s*\z/
    end

    def encrypted?(error)
      error =~ /\.EncryptedDocumentException\b/
    end
  end
end
