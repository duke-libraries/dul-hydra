require "delegate"
require "shellwords"

class FileCharacterization < SimpleDelegator

  class FITSError < DulHydra::Error; end

  def self.call(obj)
    new(obj).call
  end

  def call
    with_content_file do |path|
      fits_output = run_fits(path)
      reload
      fits.content = fits_output
      save!
    end
  end

  private

  def run_fits(path)
    output = `#{fits_command} -i #{Shellwords.escape(path)}`
    unless $?.success?
      raise FITSError, output
    end
    output
  end

  def fits_command
    File.join(DulHydra.fits_home, 'fits.sh')
  end

end
