require 'ddr-models'

module DulHydra
  extend ActiveSupport::Autoload

  autoload :Configurable
  autoload :Reports
  autoload :BatchError, 'dul_hydra/error'

  autoload_under 'ability_definitions' do
    autoload :AliasAbilityDefinitions
    autoload :ExportSetAbilityDefinitions
    autoload :BatchAbilityDefinitions
    autoload :MetadataFileAbilityDefinitions
    autoload :IngestFolderAbilityDefinitions
  end

  include DulHydra::Configurable

end
