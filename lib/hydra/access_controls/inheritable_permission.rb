module Hydra::AccessControls
  class InheritablePermission < Permission

    def initialize(args)
      super
      @vals[:inherited] = args.fetch(:inherited, false)
    end

    def inherited
      self[:inherited]
    end

  end
end
