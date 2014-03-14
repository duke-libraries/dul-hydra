module DulHydra
  autoload :Configurable, 'dul_hydra/configurable'
  autoload :Error, 'dul_hydra/error'
  autoload :ChecksumInvalid, 'dul_hydra/error'

  include DulHydra::Configurable
end
