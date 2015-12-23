class METSFolderConfiguration

  attr_reader :config

  DEFAULT_CONFIG_FILE = Rails.root.join('config', 'mets_folder.yml')

  def initialize(config_file_path = DEFAULT_CONFIG_FILE)
    @config = YAML::load(File.read(config_file_path)).symbolize_keys
  end

  def display_format_config
    config[:display_format]
  end

  def scanner_config
    config[:scanner]
  end

end
