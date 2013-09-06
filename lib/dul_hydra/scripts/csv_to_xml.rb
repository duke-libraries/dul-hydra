module DulHydra::Scripts
  class CsvToXml
    
    DEFAULT_XML_OPTIONS = { :root_node => "Table", :row_node => "Row", :include_empty_fields => false, :break_repeating_fields => true, :repeating_fields_separator => "; " }

    def initialize(opts={})
      @csv_file = opts.fetch(:csv)
      @xml_file = opts.fetch(:xml)
      @profile_file = opts.fetch(:profile, nil)
    end
    
    def execute
      load_profile if @profile_file
      start_xml
      CSV.foreach(@csv_file, csv_options) do |row|
        row_node = Nokogiri::XML::Node.new xml_options[:row_node], @xml
        # TO DO: handle scenario where row does not have headers
        row.headers.each do |header|
          if xml_options[:include_empty_fields] || !row.field(header).blank?
            case xml_options[:break_repeating_fields]
            when true
              values = row.field(header).split(xml_options[:repeating_fields_separator])
              values.each do |value|
                field_node = Nokogiri::XML::Node.new header, @xml
                field_node.content = value
                row_node.add_child field_node                
              end
            when false
              field_node = Nokogiri::XML::Node.new header, @xml
              field_node.content = row.field(header)
              row_node.add_child field_node
            end
          end
        end
        @xml.root.add_child row_node
      end
      puts @xml.to_xml
    end
    
    def start_xml
      @xml = Nokogiri::XML::Document.new
      @xml.root = Nokogiri::XML::Node.new xml_options[:root_node], @xml
    end
    
    def load_profile
      @profile = File.open(@profile_file) { |f| YAML::load(f) }
    end
    
    def csv_options
      options = Hash.new.update(CSV::DEFAULT_OPTIONS)
      options.update(@profile.fetch(:csv)) if @profile && @profile.has_key?(:csv)
      # TO DO: add facility to then overlay options with command line options
      options
    end
    
    def xml_options
      options = Hash.new.update(DEFAULT_XML_OPTIONS)
      options.update(@profile.fetch(:xml)) if @profile && @profile.has_key?(:xml)
      # TO DO: add facility to then overlay options with command line options
      options
    end
    
  end
end