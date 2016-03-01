require 'ddr-models'
require 'dul_hydra/version'

module DulHydra
  extend ActiveSupport::Autoload

  autoload :BatchError, 'dul_hydra/error'

  autoload_under 'ability_definitions' do
    autoload :AliasAbilityDefinitions
    autoload :ExportSetAbilityDefinitions
    autoload :BatchAbilityDefinitions
    autoload :MetadataFileAbilityDefinitions
    autoload :IngestFolderAbilityDefinitions
    autoload :METSFolderAbilityDefinitions
  end

  include DulHydra::Configurable

end
