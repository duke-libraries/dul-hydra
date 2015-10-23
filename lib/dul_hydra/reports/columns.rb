module DulHydra::Reports
  module Columns

    def self.field_header(key)
      if key =~ /\Atechmd_/
        key.sub! /\Atechmd_/, ""
        i18n_path = "techmd"
      else
        i18n_path = "reports.columns"
      end
      I18n.t "dul_hydra.#{i18n_path}.#{key}", default: key.titleize
    end

    PID = Column.new("id", header: "Fedora PID")

    Ddr::Index::Fields.constants(false).each do |field|
      key = field.to_s.downcase
      column = Column.new(Ddr::Index::Fields.const_get(field), header: field_header(key))
      const_set(field, column)
    end

    TechnicalMetadata = constants(false).select { |c| c.to_s =~ /\ATECHMD_/ }.map { |c| const_get(c) }

  end
end
