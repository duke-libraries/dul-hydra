module DulHydra::Scripts::Helpers
  module BatchIngestHelper
    extend ActiveSupport::Concern
    
    # Constants
    FEDORA_URI_PREFIX = "info:fedora/"
    PROVIDED = "provided"
    QDC_GENERATION_SOURCES = Set[:contentdm, :marcxml]
#    CONTENTDM_TO_QDC_XSLT_FILEPATH = "/srv/fedora-working/ingest/bin/xslt/CONTENTdm2QDC.xsl"
#    MARCXML_TO_QDC_XSLT_FILEPATH = "/srv/fedora-working/ingest/bin/xslt/MARCXML2QDC.xsl"
    CONTENTDM_TO_QDC_XSLT_FILEPATH = "#{Rails.root}/lib/assets/xslt/CONTENTdm2QDC.xsl"
    MARCXML_TO_QDC_XSLT_FILEPATH = "#{Rails.root}/lib/assets/xslt/MARCXML2QDC.xsl"

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
      
      def generate_qdc(object, qdcsource, basepath)
          xslt_filepath = eval "#{qdcsource.upcase}_TO_QDC_XSLT_FILEPATH"
          xml = File.open(metadata_filepath(object, qdcsource, basepath)) { |f| Nokogiri::XML(f) }
          xslt = File.open(xslt_filepath) { |f| Nokogiri::XSLT(f) }
          qdc = xslt.transform(xml)
#          result_xml_path = "#{basepath}qdc/#{key_identifier(object)}.xml"
#          File.open(result_xml_path, 'w') { |f| qdc.write_xml_to f }        
      end
      
      def stub_qdc()
        qdc = Nokogiri::XML::Document.new
        dc_node = Nokogiri::XML::Node.new :dc.to_s, qdc
        qdc.root = dc_node
        qdc.root.add_namespace('dcterms', 'http://purl.org/dc/terms/')
        qdc.root.add_namespace('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
        return qdc        
      end
      
      def merge_identifiers(manifest_object_identifier, ingest_object_identifier)
        manifest_identifiers = case manifest_object_identifier
        when String
          Array.new << manifest_object_identifier
        when Array
          manifest_object_identifier
        end
        identifiers = Set.new(ingest_object_identifier).merge(Set.new(manifest_identifiers)).to_a
      end
      
      def key_identifier(manifest_object)
        case manifest_object[:identifier]
        when String
          manifest_object[:identifier]
        when Array
          manifest_object[:identifier].first
        end
      end
      
      def metadata_filepath(object, qdcsource, basepath)
        type = qdcsource
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
      
      def object_metadata(object, manifest_metadata)
        metadata = Array.new
        metadata.concat(manifest_metadata) unless manifest_metadata.blank?
        metadata.concat(object[:metadata]) unless object[:metadata].blank?
        return metadata
      end
      
      def add_metadata_content_file(ingest_object, object, metadata_type, basepath)
          dsLocation = case
          when object[metadata_type].blank?
            "#{basepath}#{metadata_type}/#{key_identifier(object)}.xml"
          when object[metadata_type].start_with?("/")
            "#{object[metadata_type]}"
          else
            "#{basepath}#{metadata_type}#{File::SEPARATOR}#{object[metadata_type]}"
          end
          content = File.open(dsLocation)
          label = nil
          datastream = case metadata_type
          when "contentdm"
            label = "CONTENTdm Data for this object"
            ingest_object.contentdm
          when "digitizationguide"
            label = "Digitization Guide Data for this object"
            ingest_object.digitizationGuide
          when "dpcmetadata"
            label = "DPC Metadata Data for this object"
            ingest_object.dpcMetadata
          when "fmpexport"
            label = "FileMakerPro Export Data for this object"
            ingest_object.fmpExport
          when "jhove"
            label = "JHOVE Data for this object"
            ingest_object.jhove
          when "marcxml"
            label = "Aleph MarcXML Data for this object"
            ingest_object.marcXML
          when "tripodmets"
            label = "Tripod METS Data for this object"
            ingest_object.tripodMets
          end
          datastream.content_file = content
          datastream.dsLabel = label
          return ingest_object
      end
      
      def set_parent(ingest_object, object_model, parent_identifier_type, parent_identifier)
        parent = case parent_identifier_type
        when :id
          parent_results = parent_class(object_model).find_by_identifier(parent_identifier)
          case
          when parent_results.size == 1
            parent_results.first
          when parent_results.size > 1
            raise "Found multiple parent objects"
          else
            parent_results
          end
        when :pid
          parent_class(object_model).find(parent_identifier)
        end
        if parent.blank?
          raise "Unable to find parent"
        end
        case object_model
        when "afmodel:Item"
          ingest_object.collection = parent
        end
        return ingest_object
      end
      
      def parent_class(child_model)
        case child_model
        when "afmodel:Item"
          Collection
        when "afmodel:Component"
          Item
        end
      end
    end

  end
end