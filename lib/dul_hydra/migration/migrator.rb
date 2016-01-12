module DulHydra::Migration
  class Migrator

    attr_reader :mover

    delegate :source, :target, to: :mover

    def initialize(mover)
      @mover = mover
    end

  end
end
