module DulHydra
  autoload :Configurable, 'dul_hydra/configurable'
  autoload :Error, 'dul_hydra/error'
  autoload :ChecksumInvalid, 'dul_hydra/error'

  include DulHydra::Configurable

  def self.creatable_models
    @@creatable_models ||= ability_group_map.select {|k, v| v.key? :create}.keys
  end
end
