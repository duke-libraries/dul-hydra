module DulHydra::Scripts::Helpers
  module BatchIngestHelper
    extend ActiveSupport::Concern
    
    # Constants
    FEDORA_URI_PREFIX = "info:fedora/"
    PROVIDED = "provided"
    QDC_GENERATION_SOURCES = Set[:contentdm, :marcxml]
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
      
      def add_pid_to_master(master, key_identifier, pid)
        object_node = master.xpath("/objects/object[identifier[contains(text(), '#{key_identifier}')]]")
        case object_node.size()
        when 1
          pid_node = Nokogiri::XML::Node.new :pid.to_s, master
          pid_node.content = pid
          object_node.first.add_child(pid_node)
        when 0
          raise "Object not found in master file"
        else
          raise "Multiple objects found in master file"
        end
        return master
      end
      
      def generate_qdc(object, basepath)
          xslt_filepath = eval "#{object[:qdcsource].upcase}_TO_QDC_XSLT_FILEPATH"
          xml = File.open(metadata_filepath(object, basepath)) { |f| Nokogiri::XML(f) }
          xslt = File.open(xslt_filepath) { |f| Nokogiri::XSLT(f) }
          qdc = xslt.transform(xml)
          result_xml_path = "#{basepath}qdc/#{key_identifier(object)}.xml"
          File.open(result_xml_path, 'w') { |f| qdc.write_xml_to f }        
      end
      
      def key_identifier(manifest_object)
        case manifest_object[:identifier]
        when String
          manifest_object[:identifier]
        when Array
          manifest_object[:identifier].first
        end
      end
      
      def metadata_filepath(object, basepath)
        type = object[:qdcsource]
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
      
      def object_apo(object, manifest_apo)
        case
        when object[:adminpolicy] then AdminPolicy.find(object[:adminpolicy])
        when manifest_apo then manifest_apo
        end
      end
      
    end

  end
end