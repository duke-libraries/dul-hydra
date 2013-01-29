module DulHydra::Scripts::Helpers
  module BatchIngestHelper
    extend ActiveSupport::Concern
    
    # Constants
    FEDORA_URI_PREFIX = "info:fedora/"
    ACTIVE_FEDORA_MODEL_PREFIX = "afmodel:"
    PROVIDED = "provided"
    JHOVE_DATE_XPATH = "/xmlns:jhove/xmlns:date"
    JHOVE_SPLIT_XPATH = "/xmlns:jhove/xmlns:repInfo"
    JHOVE_URI_ATTRIBUTE = "uri"
    CONTENT_FILE_TYPES = Set[:pdf, :tif]
    QDC_GENERATION_SOURCES = Set[:contentdm, :digitizationguide, :marcxml]
    CONTENTDM_TO_QDC_XSLT_FILEPATH = "#{Rails.root}/lib/assets/xslt/CONTENTdm2QDC.xsl"
    DIGITIZATIONGUIDE_TO_QDC_XSLT_FILEPATH = "#{Rails.root}/lib/assets/xslt/DigitizationGuide2QDC.xsl"
    MARCXML_TO_QDC_XSLT_FILEPATH = "#{Rails.root}/lib/assets/xslt/MARCXML2QDC.xsl"
    VERIFYING = "Verifying..."
    PASS = "...PASS"
    FAIL = "...FAIL"

    module ClassMethods
      
      def split(source_doc, unit_xpath, identifier_element)
        parts = Hash.new
        elements = source_doc.xpath(unit_xpath)
        elements.each do |element|
          identifier = element.xpath("#{identifier_element}").text
          targetDoc = Nokogiri::XML::Document.new
          targetDoc.root = element
          parts[identifier] = targetDoc
        end
        return parts
      end

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
        object_node[:model] = "#{FEDORA_URI_PREFIX}#{ACTIVE_FEDORA_MODEL_PREFIX}#{model}"
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
          raise "Object #{key_identifier} not found in master file"
        else
          raise "Multiple objects found for #{key_identifier} in master file"
        end
        return master
      end
      
      def get_pid_from_master(master, key_identifier)
        object_node = master.xpath("/objects/object[identifier[contains(text(), '#{key_identifier}')]]")
        case object_node.size()
        when 1
          pid = object_node.xpath("pid").text
        when 0
          raise "Object #{key_identifier} not found in master file"
        else
          raise "Multiple objects found for #{key_identifier} in master file"
        end
        return pid
      end
      
      def verify_checksum(repository_object, key_identifier, checksum_doc)
        checksum_node = checksum_doc.xpath("/checksums/checksum[componentid[contains(text(), '#{key_identifier}')]]")
        checksum_value_node = checksum_node.xpath("value")
        checksum_value = checksum_value_node.text()
        contentDatastreamProfile = repository_object.content.profile(:validateChecksum => true)
        fedoraChecksumValidation = contentDatastreamProfile["dsChecksumValid"]
        externalChecksumValidation = contentDatastreamProfile["dsChecksum"].eql?(checksum_value)
        return fedoraChecksumValidation && externalChecksumValidation
      end
      
      #def add_checksum_to_master(master, key_identifier, checksum_doc, checksum_source)
      #  object_node = master.xpath("/objects/object[identifier[contains(text(), '#{key_identifier}')]]")
      #  source_checksum_node = checksum_doc.xpath("/checksums/checksum[componentid[contains(text(), '#{key_identifier}')]]")
      #  checksum_type_node = source_checksum_node.xpath("type")
      #  checksum_value_node = source_checksum_node.xpath("value")
      #  case object_node.size()
      #  when 1
      #    target_checksum_node = Nokogiri::XML::Node.new :checksum.to_s, master
      #    target_checksum_node['source'] = checksum_source
      #    target_checksum_node.add_child(checksum_type_node.dup)
      #    target_checksum_node.add_child(checksum_value_node.dup)
      #    object_node.first.add_child(target_checksum_node)
      #  when 0
      #    raise "Object not found in master file"
      #  else
      #    raise "Multiple objects found in master file"
      #  end
      #  return master
      #end
      
      def generate_qdc(object, qdcsource, basepath)
          xslt_filepath = eval "#{qdcsource.upcase}_TO_QDC_XSLT_FILEPATH"
          xml = File.open(metadata_filepath(object, qdcsource, basepath)) { |f| Nokogiri::XML(f) }
          xslt = File.open(xslt_filepath) { |f| Nokogiri::XSLT(f) }
          qdc = xslt.transform(xml)
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
      
      def add_content_file(ingest_object, filename)
        if ingest_object.datastreams.keys.include?("content")
          file = File.open(filename)
          ingest_object.content.content_file = file
          ingest_object.content.dsLabel = "Content file for this object"
          ingest_object.save
          file.close
          ingest_object.reload
        else
          raise "Ingest object does not have a 'content' datastream"
        end
        return ingest_object
      end
      
      def add_metadata_content_file(ingest_object, object, metadata_type, basepath)
          dsLocation = case
          when object[metadata_type].blank?
            "#{basepath}#{metadata_type}/#{key_identifier(object)}.xml"
          when object[metadata_type].start_with?("/")
            "#{object[metadata_type]}"
          else
            "#{basepath}#{metadata_type}/#{object[metadata_type]}"
          end
          content = File.open(dsLocation)
          label = nil
          datastream = case metadata_type
          when "contentdm"
            label = "CONTENTdm Data for this object"
            ingest_object.contentdm
          when "contentmetadata"
            label = "Structural Content Data for this object"
            ingest_object.contentMetadata
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
      
      def datastream_name(alternate_term)
        case alternate_term
        when "contentmetadata"
          "contentMetadata"
        when "contentstructure"
          "contentMetadata"
        when "digitizationguide"
          "digitizationGuide"
        when "dpcmetadata"
          "dpcMetadata"
        when "fmpexport"
          "fmpExport"
        when "jhove"
          "jhove"
        when "marcxml"
          "marcXML"
        when "qdc"
          "descMetadata"
        when "tripodmets"
          "tripodMets"
        else
          alternate_term
        end
      end
      
      def get_parent(repository_object)
        parent = nil
        case
        when repository_object.class == Item
          parent = repository_object.collection
        when repository_object.class == Component
          parent = repository_object.container
        end
        return parent
      end
      
      def get_children(repository_object)
        children = []
        case
        when repository_object.class == Collection
          children = repository_object.items
        when repository_object.class == Item
          children = repository_object.parts
        end
        return children
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
        when "Item"
          ingest_object.collection = parent
        when "Component"
          ingest_object.container = parent
        end
        return ingest_object
      end
      
      def parent_class(child_model)
        case child_model
        when "Item"
          Collection
        when "Component"
          Item
        end
      end
      
      def write_preservation_event(ingest_object, event_type, event_outcome, details)
        event_label = case event_type
        when PreservationEvent::INGESTION
          "Object ingestion"
        when PreservationEvent::VALIDATION
          "Object ingest validation"
        end
        event = PreservationEvent.new(:label => event_label,
                                      :event_type => event_type,
                                      :event_date_time => Time.now.utc.strftime(PreservationEvent::DATE_TIME_FORMAT),
                                      :event_outcome => event_outcome,
                                      :linking_object_id_type => PreservationEvent::OBJECT,
                                      :linking_object_id_value => ingest_object.internal_uri,
                                      :event_detail => details,
                                      :for_object => ingest_object)
        event.save
      end
      
      def create_content_metadata_document(repository_object, sequencing_start, sequencing_length)
        parts = repository_object.parts
        hash = Hash.new
        parts.each do |part|
          hash[part.identifier.first.slice(sequencing_start, sequencing_length)] = part.pid
        end
        sorted_keys = hash.keys.sort
        cm = Nokogiri::XML::Document.new
        root_node = Nokogiri::XML::Node.new "mets", cm
        cm.root = root_node
        cm.root.default_namespace = 'http://www.loc.gov/METS/'
        cm.root.add_namespace_definition('xlink', 'http://www.w3.org/1999/xlink')
        fileSec_node = Nokogiri::XML::Node.new "fileSec", cm
        fileGrp_node = Nokogiri::XML::Node.new "fileGrp", cm
        fileGrp_node['ID'] = 'GRP01'
        fileGrp_node['USE'] = 'Master Image'
        structMap_node = Nokogiri::XML::Node.new "structMap", cm
        div0_node = Nokogiri::XML::Node.new "div", cm        
        sorted_keys.each_with_index do |key, index|
          file_node = Nokogiri::XML::Node.new "file", cm
          file_node['ID'] = "FILE#{key}"
          fLocat_node = Nokogiri::XML::Node.new "FLocat", cm
          fLocat_node['xlink:href'] = "#{hash[key]}/content"
          fLocat_node['LOCTYPE'] = 'URL'
          file_node.add_child(fLocat_node)
          fileGrp_node.add_child(file_node)
          div1_node = Nokogiri::XML::Node.new "div", cm
          div1_node['ORDER'] = (index + 1).to_s
          fptr_node = Nokogiri::XML::Node.new "fptr", cm
          fptr_node['FILEID'] = "FILE#{key}"
          div1_node.add_child(fptr_node)
          div0_node.add_child(div1_node)
        end
        fileSec_node.add_child(fileGrp_node)
        structMap_node.add_child(div0_node)
        root_node.add_child(fileSec_node)
        root_node.add_child(structMap_node)
        return cm
      end

      def validate_object_exists(model_class, pid)
        valid = true
        begin
          object = ActiveFedora::Base.find(pid, :cast => true)
        rescue ActiveFedora::ObjectNotFoundError
          valid = false
        end
        if valid
          begin
            if !object.conforms_to?(model_class.constantize)
              valid = false
            end
          rescue
            valid = false
          end
        end
        return valid
      end

      def validate_datastream_populated(datastream, object)
        valid = true
        if !object.datastreams.keys.include?(datastream)
          valid = false
        elsif object.datastreams["#{datastream}"].size.nil? || object.datastreams["#{datastream}"].size == 0
          valid = false
        end
        return valid
      end
      
    end
  end
end