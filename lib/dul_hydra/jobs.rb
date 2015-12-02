module DulHydra
  module Jobs
    extend Deprecation

    def self.const_missing(name)
      case name
      when :FixityCheck
        Deprecation.warn(Jobs, "`DulHydra::Jobs::FixityCheck` is deprecated and will be removed in dul-hydra 5.0; use `Ddr::Jobs::FixityCheck` instead.")
        Ddr::Jobs::FixityCheck
      when :UpdateIndex
        Deprecation.warn(Jobs, "`DulHydra::Jobs::UpdateIndex` is deprecated and will be removed in dul-hydra 5.0; use `Ddr::Jobs::UpdateIndex` instead.")
        Ddr::Jobs::UpdateIndex
      else
        super
      end
    end

  end
end
