module DulHydra::Scripts::Helpers
  module BatchIngestHelper
    extend ActiveSupport::Concern
    
    # Constants
    FEDORA_URI_PREFIX = "info:fedora/"
    PROVIDED = "provided"
    CONTENTDM_SUBPATH = "contentdm/"
    DIGITIZATIONGUIDE_SUBPATH = "digitizationGuide/"
    FMPEXPORT_SUBPATH = "fmpExport/"
    MARCXML_SUBPATH = "marcXML/"
    MASTER_SUBPATH = "master/"
    QDC_SUBPATH = "qdc/"
    MARCXML_TO_QDC_XSLT_FILEPATH = "/srv/fedora-working/ingest/bin/xslt/MARCXML2QDC.xsl"
    
    module ClassMethods
      
      def load_yaml(path_to_yaml)
        File.open(path_to_yaml) { |f| YAML::load(f) }
      end
      
      def create_master_document()
        master = Nokogiri::XML::Document.new
        objects_node = Nokogiri::XML::Node.new :objects.to_s, master
        master.root = objects_node
        return master
      end

      def add_manifest_object_to_master(master, object, manifest_model)
        model = object[:model] || manifest_model
        object_node = Nokogiri::XML::Node.new :object.to_s, master
        object_node[:model] = "#{FEDORA_URI_PREFIX}#{model}"
        identifier_node = Nokogiri::XML::Node.new :identifier.to_s, master
        identifier_node.content = key_identifier(object)
        object_node.add_child(identifier_node)
        master.root.add_child(object_node)
        return master
      end
      
      def create_qdc_from_marcxml(object, marcxml, xslt)
        source_xml_path = case
        when object[:marcxml].blank?
          "#{basepath}#{MARCXML_SUBPATH}#{key_identifier(object)}.xml"
        when object[:marcxml].start_with?("/")
          object[:marcxml]
        else
          "#{basepath}#{MARCXML_SUBPATH}#{object[:marcxml]}"
        end
        xsl_path = "/srv/fedora-working/ingest/bin/xslt/MARCXML2QDC.xsl"
        doc = File.open(source_xml_path) { |f| Nokogiri::XML(f) }
        xslt = File.open(xsl_path) { |f| Nokogiri::XSLT(f) }
        xslt.transform(doc)
      end
      
      def key_identifier(object)
        case object[:identifier]
        when String
          object[:identifier]
        when Array
          object[:identifier].first
        end
      end

      def marcxml_filepath(object, basepath)
        case
        when object[:marcxml].blank?
          "#{basepath}#{MARCXML_SUBPATH}#{key_identifier(object)}.xml"
        when object[:marcxml].start_with?("/")
          object[:marcxml]
        else
          "#{basepath}#{MARCXML_SUBPATH}#{object[:marcxml]}"
        end        
      end
      
    end

  end
end