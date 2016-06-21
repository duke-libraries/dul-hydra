require 'ddr-models'
require 'dul_hydra/version'
require 'dul_hydra/error'

module DulHydra
  extend ActiveSupport::Autoload

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
