module DulHydra::Scripts::Helpers
  module BatchIngestHelper
    extend ActiveSupport::Concern
    
    # Constants
    FEDORA_URI_PREFIX = "info:fedora/"
    PROVIDED = "provided"
    CONTENTDM_TO_QDC_XSLT_FILEPATH = "/srv/fedora-working/ingest/bin/xslt/CONTENTdm2QDC.xsl"
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
      
      def key_identifier(object)
        case object[:identifier]
        when String
          object[:identifier]
        when Array
          object[:identifier].first
        end
      end
      
      def metadata_filepath(type, object, basepath)
        case
        when object["#{type}"].blank?
          "#{basepath}#{type}#{File::SEPARATOR}#{key_identifier(object)}.xml"
        when object["#{type}"].start_with?("/")
          object["#{type}"]
        else
          filename = object["#{type}"]
          "#{basepath}#{type}#{File::SEPARATOR}#{filename}"
        end
      end
      
      def master_path(manifest)
        master_path = case
        when manifest[:master].blank?
          "#{manifest[:basepath]}master/master.xml"
        when manifest[:master].start_with?("/")
          manifest[:master]
        else
          "#{manifest[:basepath]}master/#{manifest[:master]}"
        end      
      end
      
    end

  end
end