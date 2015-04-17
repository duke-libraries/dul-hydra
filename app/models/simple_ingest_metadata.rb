class SimpleIngestMetadata

  attr_reader :metadata_filepath, :metadata_profile

  DATA_PREFIX = 'data'

  # Used in accommodation of case and spacing errors in column headings
  NORMALIZED_TERMS = Ddr::Vocab::Vocabulary.term_names(RDF::DC).map(&:downcase).map(&:to_s)

  def initialize(metadata_filepath, metadata_profile)
    @metadata_filepath = metadata_filepath
    @metadata_profile = metadata_profile
    validate_headers
  end

  def metadata(locator)
    metadata = {}
    loc = locator.present? ? File.join(DATA_PREFIX, locator) : DATA_PREFIX
    if metadata_grid[loc]
      metadata_grid[loc].each do |heading, field_contents|
        unless field_contents.blank?
          metadata = add_field_to_metadata(metadata, heading, field_contents)
        end
      end
    end
    metadata
  end

  private

  def add_field_to_metadata(metadata, heading, field_contents)
    metadata[heading] ||= []
    metadata[heading] += Array(parse_field_contents(heading, field_contents))
    metadata
  end

  def parse_field_contents(heading, field_contents)
    if field_contents && repeatable_fields.include?(heading)
      field_contents.split(repeating_fields_separator).map(&:strip)
    else
      field_contents
    end
  end

  def validate_headers
    invalid_headers = []
    as_csv_table.headers[1..-1].each do |header|
      invalid_headers << header unless valid_header?(header)
    end
    unless invalid_headers.empty?
      raise ArgumentError, "Invalid metadata terms in header row: #{invalid_headers.join(', ')}"
    end
  end

  def valid_header?(header)
    NORMALIZED_TERMS.include?(normalize_header(header))
  end

  def normalize_header(header)
    header.downcase.gsub(/\s+/, "")
  end

  def metadata_grid
    unless @metadata_grid
      @metadata_grid = {}
      as_csv_table.each do |row|
        locator = row.field(0)
        row.delete(0)
        @metadata_grid[locator] = row
      end
    end
    @metadata_grid
  end

  def as_csv_table
    @csv_table ||= CSV.read(metadata_filepath, metadata_profile[:csv])
  end

  def repeating_fields_separator
    metadata_profile[:parse][:repeating_fields_separator]
  end

  def repeatable_fields
    metadata_profile[:parse][:repeatable_fields]
  end

  # Accommodate case and spacing errors in column headings
  CSV::HeaderConverters[:canonicalize] = lambda{ |h|
    NORMALIZED_TERMS.index(h.downcase.gsub(/\s+/, "")) ?
      Ddr::Vocab::Vocabulary.term_names(RDF::DC)[NORMALIZED_TERMS.index(h.downcase.gsub(/\s+/, ""))].to_s :
      h
  }

end