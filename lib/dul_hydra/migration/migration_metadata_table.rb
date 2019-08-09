module DulHydra
  module Migration
    class MigrationMetadataTable

      DEFAULT_OUTPUT_FILEPATH = '/tmp/migration_metadata.txt'

      attr_reader :object_ids

      def initialize(object_ids)
        @object_ids = Array(object_ids)
      end

      def as_csv_table
        migration_metadata = object_ids.map do |object_id|
          object = ActiveFedora::Base.find(object_id)
          MigrationMetadata.new(object).migration_metadata
        end
        # column index  - keys are terms, values are max occurrences of field
        col_index = Hash.new
        migration_metadata.each do |mm|
          mm.keys.each do |term|
            occurs = Array(mm[term]).size
            col_index[term] = [ occurs, col_index.fetch(term, 0) ].max
          end
        end
        # headers
        cols = col_index.inject([]) { |h, idx| h.concat(Array.new(*idx.reverse)) }
        rows = migration_metadata.collect do |mm|
          row = Array.new(cols.size)
          col_index.keys.each do |term|
            start = cols.index(term)
            values = Array(mm[term])
            row[start, values.size] = values
          end
          CSV::Row.new(cols, row)
        end
        CSV::Table.new(rows)
      end

      def write_to_file(filepath)
        File.open(filepath, 'wb') do |f|
          f.puts as_csv_table.to_csv(DulHydra.csv_options)
        end
      end

    end
  end
end



# File.open('/tmp/test.csv', 'wb') { |w| w.puts mmt.merged_metadata.to_csv(DulHydra.csv_options) }
#  x = CSV.read('/tmp/test.csv', DulHydra.csv_options)
