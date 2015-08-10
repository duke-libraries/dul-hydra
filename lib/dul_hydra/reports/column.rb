module DulHydra::Reports
  class Column

    attr_reader :field, :header

    def initialize(field, header: nil)
      @field = field
      @header = header || field
    end

    def to_s
      field
    end

  end
end
