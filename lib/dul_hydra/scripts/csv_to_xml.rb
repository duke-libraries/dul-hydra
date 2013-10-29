module DulHydra::Scripts
  class CsvToXml
    
    DEFAULT_XML_OPTIONS = { 
      :root_node => "Table",
      :row_node => "Row", 
      :include_empty_fields => false, 
      :break_repeating_fields => true, 
      :repeating_fields_separator => "; ",
      :exclude_from_repeating_fields => [],
      :split => false,
      :split_filename_source => "Identifier"
    }

    def initialize(opts={})
      @csv_file = opts.fetch(:csv)
      @xml_file = opts.fetch(:xml)
      @profile_file = opts.fetch(:profile, nil)
      @schema_map_file = opts.fetch(:schema_map, nil)
    end
    
    def execute
      load_profile if @profile_file
      load_schema_map if @schema_map_file
      start_xml unless xml_options[:split]
      CSV.foreach(@csv_file, csv_options) do |row|
        start_xml if xml_options[:split]
        row_node = Nokogiri::XML::Node.new xml_options[:row_node], @xml unless xml_options[:split]
        # TO DO: do we need to handle scenario where row does not have headers?
        row.headers.each do |header|
          if xml_options[:include_empty_fields] || !row.field(header).blank?
            if xml_options[:break_repeating_fields] && !xml_options[:exclude_from_repeating_fields].include?(header)
              values = row.field(header).split(xml_options[:repeating_fields_separator])
              values.each do |value|
                row_node = add_field_to_node(xml_options[:split] ? @xml.root : row_node, header, value)
              end
            else
              row_node = add_field_to_node(xml_options[:split] ? @xml.root : row_node, header, row.field(header))
            end
          end
        end
        @xml.root.add_child row_node unless xml_options[:split]
        if xml_options[:split]
          file_path = nil
          if File.exists?(@xml_file)
            dir = File.directory?(@xml_file) ? @xml_file : File.dirname(@xml_file)
          else
            dir = @xml_file
          end
          FileUtils.mkdir_p dir
          file_path = File.join(dir, row.field(xml_options[:split_filename_source]) + '.xml')
          write_xml(file_path)
        end
      end
      write_xml(@xml_file) unless xml_options[:split]
    end
    
    def add_field_to_node(parent_node, field_name, field_content)
      # TO DO: only works for umapped = exclude -- do we need to handle any other cases?
      if field_map?
        if field_map[field_name]
          fld_name = field_map[field_name]
          if schema_fields[:namespace]
            fld_name = "#{schema_fields[:namespace]}:#{fld_name}"
          end
        end
      else
        fld_name = field_name.gsub(" ", "_")
      end
      if fld_name
        field_node = Nokogiri::XML::Node.new fld_name, @xml
        field_node.content = field_content
        parent_node.add_child field_node
      end
      parent_node
    end
    
    def start_xml
      @xml = Nokogiri::XML::Document.new
      @xml.root = root_node
    end
    
    def root_node
      case schema_root
      when nil
        Nokogiri::XML::Node.new xml_options[:root_node], @xml
      else        
        node = Nokogiri::XML::Node.new schema_root[:name], @xml
        if schema_root[:namespaces]
          schema_root[:namespaces].each do |ns|
            node.add_namespace(ns[:prefix], ns[:href])
          end
        end
        node
      end
    end
    
    def write_xml(file_path)
      File.open(file_path,'w') {|f| @xml.write_xml_to f}
    end
    
    def load_profile
      @profile = File.open(@profile_file) { |f| YAML::load(f) }
    end
    
    def csv_options
      options = Hash.new.update(CSV::DEFAULT_OPTIONS)
      options.update(@profile.fetch(:csv)) if @profile && @profile.has_key?(:csv)
      # TO DO: add facility to then overlay options with command line options?
      options
    end
    
    def xml_options
      options = Hash.new.update(DEFAULT_XML_OPTIONS)
      options.update(@profile.fetch(:xml)) if @profile && @profile.has_key?(:xml)
      # TO DO: add facility to then overlay options with command line options?
      options
    end
    
    def load_schema_map
      @schema_map = File.open(@schema_map_file) { |f| YAML::load(f) }
    end
    
    def schema_root
      @schema_map ? @schema_map[:root_node] : nil
    end
    
    def schema_fields
      @schema_map[:fields]
    end
    
    def field_map
      schema_fields[:field_map]
    end
    
    def field_map?
      @schema_map && schema_fields && field_map
    end
    
  end
end