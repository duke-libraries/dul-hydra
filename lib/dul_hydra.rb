require 'ddr-models'

module DulHydra
  extend ActiveSupport::Autoload

  autoload :BatchError, 'dul_hydra/error'
  autoload :Configurable
  autoload :Error
  autoload :Jobs
  autoload :Queues

  autoload_under 'ability_definitions' do
    autoload :AliasAbilityDefinitions
    autoload :ExportSetAbilityDefinitions
    autoload :BatchAbilityDefinitions
    autoload :MetadataFileAbilityDefinitions
    autoload :IngestFolderAbilityDefinitions
    autoload :SimpleIngestAbilityDefinitions
  end

  include DulHydra::Configurable

end
