module DulHydra

  autoload :Configurable, 'dul_hydra/configurable'

  autoload :Error, 'dul_hydra/error'
  autoload :ChecksumInvalid, 'dul_hydra/error'
  autoload :VirusFoundError, 'dul_hydra/error'

  include DulHydra::Configurable

  def self.external_file_subpath_regexp
    @@external_file_subpath_regexp ||=
      begin
        pattern = external_file_subpath_pattern
        unless pattern.respond_to?(:each)
          # pattern might be a string, e.g., "1, 1, 2"
          pattern = pattern.split(/\s?,/).map(&:to_i)
        end
        Regexp.new pattern.each_with_object("^") {|p, memo| memo << "(\\h{#{p}})"}
      end
  end

end
