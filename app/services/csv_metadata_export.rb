class CSVMetadataExport < Ddr::Index::CSVQueryResult

  def csv_opts
    super.tap do |opts|
      if DulHydra.csv_mv_separator != CSV_MV_SEPARATOR
        opts[:converters].unshift(replace_csv_mv_separator)
      end
    end
  end

  def replace_csv_mv_separator
    lambda { |f| f.gsub(/(?<!\\)#{Regexp.escape(CSV_MV_SEPARATOR)}/, DulHydra.csv_mv_separator) rescue f }
  end

end
