require 'ddr-models'
require 'dul_hydra/version'

module DulHydra
  extend ActiveSupport::Autoload

  autoload :BatchError, 'dul_hydra/error'
  autoload :Configurable
  autoload :DescriptiveMetadataTable
  autoload :Error
  autoload :Fixity
  autoload :Jobs
  autoload :Queues
  autoload :MetadataTable
  autoload :Reports
  autoload :Scripts

  autoload_under 'ability_definitions' do
    autoload :AliasAbilityDefinitions
    autoload :ExportSetAbilityDefinitions
    autoload :BatchAbilityDefinitions
    autoload :MetadataFileAbilityDefinitions
    autoload :IngestFolderAbilityDefinitions
  end

  include DulHydra::Configurable

end
