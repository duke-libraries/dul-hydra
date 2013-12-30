module DulHydra

  # Abstract superclass
  class MetadataTable

    include Enumerable

    attr_reader :table

    def initialize(objects)
      # column index - keys are terms, values are max occurrences of field
      col_index = Hash.new
      objects.each do |obj|
        terms.each do |term|
          occurs = term_values(obj, term).size
          next if occurs == 0
          col_index[term] = [occurs, col_index.fetch(term, 0)].max 
        end
      end

      # headers
      cols = col_index.inject([:pid]) { |h, idx| h.concat(Array.new(*idx.reverse)) }

      # rows
      rows = objects.collect do |obj|
        row = Array.new(cols.size)
        row[0] = obj.pid
        col_index.keys.each do |term|
          start = cols.index(term)
          values = term_values(obj, term)
          row[start, values.size] = values
        end
        CSV::Row.new(cols, row)
      end

      @table = CSV::Table.new(rows)
    end    

    def method_missing(method, *args)
      if table.respond_to?(method)
        table.send(method, *args)
      else
        super
      end
    end

    def rows
      to_a
    end

    def ==(other)
      table == other.table
    end

    def each(&block)
      table.each(&block)
    end
    
    # terms to read from objects
    def terms
      raise NotImplementedError
    end

    # datastream id from which read object terms
    def datastream_id
      raise NotImplementedError
    end

    def term_values(obj, term)
      obj.datastreams[datastream_id].send(term)
    end

    def to_csv(opts = Hash.new)
      table.to_csv(csv_options.merge(opts))
    end

    def col_sep
      "\t"
    end
    
    def encoding
      "UTF-8"
    end

    def header_converters
      :symbol
    end

    def csv_options
      {
        encoding: encoding,
        col_sep: col_sep,
        headers: true,
        write_headers: true,
        header_converters: header_converters
      }
    end

  end 

end
