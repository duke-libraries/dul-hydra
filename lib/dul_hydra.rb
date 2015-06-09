require 'ddr-models'

module DulHydra

  autoload :Configurable, 'dul_hydra/configurable'
  autoload :BatchError, 'dul_hydra/error'

  include DulHydra::Configurable

end
