require 'ddr-models'
require 'dul_hydra/version'
require 'dul_hydra/error'

module DulHydra
  extend ActiveSupport::Autoload

  def self.const_missing(name)
    if name == :Fixity
      Deprecation.warn(self, "`DulHydra::Fixity` is deprecated and will be removed in dul-hydra 6.0." \
                             " Use `BatchFixityCheck` instead. (called from #{caller.first})")
      ::BatchFixityCheck
    else
      super
    end
  end

  autoload :Configurable

  autoload_under 'ability_definitions' do
    autoload :AliasAbilityDefinitions
    autoload :ExportSetAbilityDefinitions
    autoload :BatchAbilityDefinitions
    autoload :MetadataFileAbilityDefinitions
    autoload :IngestFolderAbilityDefinitions
    autoload :METSFolderAbilityDefinitions
    autoload :SimpleIngestAbilityDefinitions
  end

  include Configurable
end
