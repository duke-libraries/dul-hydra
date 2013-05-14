# log4r
require 'log4r'
require 'log4r/logger'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'

module DulHydra::Scripts::Helpers
  module BatchIngestHelper
    extend ActiveSupport::Concern

    include Log4r
    
    # Constants
    LOG_CONFIG_FILEPATH = File.join(Rails.root, 'config', 'log4r_batch_ingest.yml')
    FEDORA_URI_PREFIX = "info:fedora/"
    ACTIVE_FEDORA_MODEL_PREFIX = "afmodel:"
    GENERATE = "generate"
    PROVIDED = "provided"
    JHOVE_DATE_XPATH = "/xmlns:jhove/xmlns:date"
    JHOVE_SPLIT_XPATH = "/xmlns:jhove/xmlns:repInfo"
    JHOVE_URI_ATTRIBUTE = "uri"
    CONTENT_FILE_TYPES = Set[:pdf, :tif]
    DESC_METADATA_GENERATION_SOURCES = Set[:contentdm, :digitizationguide, :marcxml, :tripodmets]
    CONTENTDM_TO_DESC_METADATA_XSLT_FILEPATH = File.join(Rails.root, 'lib', 'assets', 'xslt', 'CONTENTdm2QDC.xsl')
    DIGITIZATIONGUIDE_TO_DESC_METADATA_XSLT_FILEPATH = File.join(Rails.root, 'lib', 'assets', 'xslt', 'DigitizationGuide2QDC.xsl')
    MARCXML_TO_DESC_METADATA_XSLT_FILEPATH = File.join(Rails.root, 'lib', 'assets', 'xslt', 'MARCXML2QDC.xsl')
    TRIPODMETS_TO_DESC_METADATA_XSLT_FILEPATH = File.join(Rails.root, 'lib', 'assets', 'xslt', 'TripodMETS2QDC.xsl')
    VERIFYING = "Verifying..."
    PASS = "...PASS"
    FAIL = "...FAIL"
    DATA_TYPE_TO_DATASTREAM_NAME = {
      "content" => DulHydra::Datastreams::CONTENT,
      "contentdm" => DulHydra::Datastreams::CONTENTDM,
      "contentmetadata" => DulHydra::Datastreams::CONTENT_METADATA,
      "contentstructure" => DulHydra::Datastreams::CONTENT_METADATA,
      "descmetadata" => DulHydra::Datastreams::DESC_METADATA,
      "digitizationguide" => DulHydra::Datastreams::DIGITIZATION_GUIDE,
      "dpcmetadata" => DulHydra::Datastreams::DPC_METADATA,
      "fmpexport" => DulHydra::Datastreams::FMP_EXPORT,
      "jhove" => DulHydra::Datastreams::JHOVE,
      "marcxml" => DulHydra::Datastreams::MARCXML,
      "tripodmets" => DulHydra::Datastreams::TRIPOD_METS
    }

    module ClassMethods
      
      # prep ingest post
      def config_logger(logger_name, basepath)
        log_config = YAML.load_file(LOG_CONFIG_FILEPATH)
        YamlConfigurator['basepath'] = basepath
        loggers = log_config['log4r_config']['loggers']
        outputters = log_config['log4r_config']['outputters']
        this_logger = loggers.detect { |logger| logger['name'].eql?(logger_name) }
        this_logger_outputter_names = this_logger['outputters']
        this_logger_outputters = outputters.select { |outputter| this_logger_outputter_names.include?(outputter['name']) }
        this_logger_outputters.each do |this_logger_outputter|
          if this_logger_outputter['filename']
            dirname = File.dirname(this_logger_outputter['filename'])
            dirname.gsub!('#{basepath}', basepath)
            FileUtils.mkdir_p dirname unless File.exists?(dirname)
          end
        end
        YamlConfigurator.decode_yaml(log_config['log4r_config'])
        return Log4r::Logger[logger_name]
      end
      
      # prep ingest post
      def write_xml_file(xmldoc, filepath)
        dirname = File.dirname(filepath)
        FileUtils.mkdir_p dirname unless File.exists?(dirname)
        File.open(filepath, "w") { |f| xmldoc.write_xml_to f }        
      end

      # prep
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

      # prep ingest
      def load_yaml(path_to_yaml)
        File.open(path_to_yaml) { |f| YAML::load(f) }
      end
      
      #prep
      def master_document(master_path)
        case
        when File.exists?(master_path)
          File.open(master_path) { |f| Nokogiri::XML(f) }
        else
          create_master_document()
        end
      end

      # internal master_document()
      def create_master_document()
        master = Nokogiri::XML::Document.new
        objects_node = Nokogiri::XML::Node.new :objects.to_s, master
        master.root = objects_node
        return master
      end

      # prep
      def add_manifest_object_to_master(master, object, manifest_model)
        model = object[:model] || manifest_model
        object_node = Nokogiri::XML::Node.new :object.to_s, master
        identifier_node = Nokogiri::XML::Node.new :identifier.to_s, master
        identifier_node.content = key_identifier(object)
        object_node.add_child(identifier_node)
        master.root.add_child(object_node)
        return master
      end
      
      #ingest
      def add_pid_to_master(master, key_identifier, pid)
        object_node = master.xpath("/objects/object[identifier[text() = '#{key_identifier}']]")
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
      
      # ingest
      def get_pid_from_master(master, identifier)
        object_node = master.xpath("/objects/object[identifier[text() = '#{identifier}']]")
        case object_node.size()
        when 1
          pid = object_node.xpath("pid").text
        when 0
          raise "Object #{identifier} not found in master file"
        else
          raise "Multiple objects found for #{identifier} in master file"
        end
        return pid
      end
      
      def verify_checksum(repository_object, key_identifier, checksum_doc)
        checksum_node = checksum_doc.xpath("/checksums/checksum[componentid[text() = '#{key_identifier}']]")
        checksum_value_node = checksum_node.xpath("value")
        checksum_value = checksum_value_node.text()
        contentDatastreamProfile = repository_object.content.profile(:validateChecksum => true)
        fedoraChecksumValidation = contentDatastreamProfile["dsChecksumValid"]
        externalChecksumValidation = contentDatastreamProfile["dsChecksum"].eql?(checksum_value)
        return fedoraChecksumValidation && externalChecksumValidation
      end
      
      # prep
      def generate_desc_metadata(object, descmetadatasource, basepath)
          xslt_filepath = eval "#{descmetadatasource.upcase}_TO_DESC_METADATA_XSLT_FILEPATH"
          xml = case descmetadatasource
          when "tripodmets"
            raw = File.open(metadata_filepath(object, "tripodmets", basepath)) { |f| f.read }
            tripodmets_dcterms_namespace_uri = "http://purl.org/dc/terms"
            canonical_dcterms_namespace_uri = "http://purl.org/dc/terms/"
            canonicalized = raw.gsub("#{tripodmets_dcterms_namespace_uri}\"", "#{canonical_dcterms_namespace_uri}\"")
            Nokogiri::XML(canonicalized)
          else
            File.open(metadata_filepath(object, descmetadatasource, basepath)) { |f| Nokogiri::XML(f) }
          end
#          xml = File.open(metadata_filepath(object, descmetadatasource, basepath)) { |f| Nokogiri::XML(f) }
          xslt = File.open(xslt_filepath) { |f| Nokogiri::XSLT(f) }
          desc_metadata = xslt.transform(xml)
      end
      
      # prep
      def stub_desc_metadata()
        desc_metadata = Nokogiri::XML::Document.new
        dc_node = Nokogiri::XML::Node.new :dc.to_s, desc_metadata
        desc_metadata.root = dc_node
        desc_metadata.root.add_namespace('dcterms', 'http://purl.org/dc/terms/')
        desc_metadata.root.add_namespace('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
        return desc_metadata
      end
      
      # ingest
      def merge_identifiers(manifest_object_identifier, ingest_object_identifier)
        manifest_identifiers = case manifest_object_identifier
        when String
          Array.new << manifest_object_identifier
        when Array
          manifest_object_identifier
        end
        identifiers = Set.new(ingest_object_identifier).merge(Set.new(manifest_identifiers)).to_a
      end
      
      # prep
      def key_identifier(manifest_object)
        case manifest_object[:identifier]
        when String
          manifest_object[:identifier]
        when Array
          manifest_object[:identifier].first
        end
      end
      
      # internal generate_desc_metadata()
      def metadata_filepath(object, metadata, basepath)
        case
        when object[metadata].blank?
          File.join(basepath, metadata, "#{key_identifier(object)}.xml")
        when object[metadata].start_with?(File::SEPARATOR)
          object[metadata]
        else
          File.join(basepath, metadata, object[metadata])
        end
      end
      
      # prep ingest post
      def master_path(manifest_master, manifest_basepath)
        master_path = case
        when manifest_master.blank?
          File.join(manifest_basepath, 'master', 'master.xml')
        when manifest_master.start_with?(File::SEPARATOR)
          manifest_master
        else
          File.join(manifest_basepath, 'master', manifest_master)
        end      
      end
      
      # ingest
      def object_apo(object, manifest_apo)
        case
        when object[:adminpolicy] then AdminPolicy.find(object[:adminpolicy])
        when manifest_apo then manifest_apo
        end
      end
      
      # ingest
      def object_metadata(object, manifest_metadata)
        metadata = Array.new
        metadata.concat(manifest_metadata) unless manifest_metadata.blank?
        metadata.concat(object[:metadata]) unless object[:metadata].blank?
        return metadata
      end
      
      # ingest
      def add_content_file(ingest_object, filename)
        if ingest_object.datastreams.keys.include?(DulHydra::Datastreams::CONTENT)
          file = File.open(filename)
          ingest_object.content.content_file = file
          ingest_object.save
          file.close
          ingest_object.reload
        else
          raise "Ingest object does not have a #{DulHydra::Datastreams::CONTENT} datastream"
        end
        return ingest_object
      end
      
      # ingest
      def add_metadata_content_file(ingest_object, object, metadata_type, basepath)
        dsLocation = metadata_filepath(object, metadata_type, basepath)
        content = File.open(dsLocation)
        datastream = DATA_TYPE_TO_DATASTREAM_NAME[metadata_type.downcase]
        ingest_object.datastreams[datastream].content_file = content
        return ingest_object
      end
      
      # ingest
      def set_parent(ingest_object, parent_identifier_type, parent_identifier)
        parent = case parent_identifier_type
        when :pid
          DulHydra::Models::Base.find(parent_identifier, :cast => true)
        end
        if parent.blank?
          raise "Unable to find parent"
        end
        ingest_object.parent = parent
        return ingest_object
      end
      
      # ingest
      def set_collection(ingest_object, collection_identifier_type, collection_identifer)
        collection = case collection_identifier_type
        when :id
          results = Collection.find_by_identifier(collection_identifer)
          case
          when results.size == 1
            results.first
          when results.size > 1
            raise "Found multiple collections"
          else
            results
          end
        when :pid
          Collection.find(collection_identifer)
        end
        if collection.blank?
          raise "Unable to find collection"
        end
        ingest_object.collection = collection
        return ingest_object
      end
      
      # ingest
      def write_preservation_event(ingest_object, event_type, event_outcome, details, outcome_details)
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
                                      :event_outcome_detail_note => outcome_details,
                                      :for_object => ingest_object)
        event.save
      end
      
      # post
      def create_content_metadata_document(repository_object, contentstructure)
        sequence_start = contentstructure[:sequencestart]
        sequence_length = contentstructure[:sequencelength]
        parts = repository_object.children
        hash = Hash.new
        parts.each do |part|
          hash[part.identifier.first.slice(sequence_start, sequence_length)] = part.pid
        end
        sorted_keys = hash.keys.sort
        cm = Nokogiri::XML::Document.new
        root_node = Nokogiri::XML::Node.new "mets", cm
        cm.root = root_node
        cm.root.default_namespace = 'http://www.loc.gov/METS/'
        cm.root.add_namespace_definition('xlink', 'http://www.w3.org/1999/xlink')
        fileSec_node = Nokogiri::XML::Node.new "fileSec", cm
        fileGrp_node = Nokogiri::XML::Node.new "fileGrp", cm
        fileGrp_node['ID'] = contentstructure[:filegrp_id] || 'GRP01'
        fileGrp_node['USE'] = contentstructure[:filegrp_use] || 'Master Image'
        structMap_node = Nokogiri::XML::Node.new "structMap", cm
        div0_node = Nokogiri::XML::Node.new "div", cm
        div0_node['ID'] = contentstructure[:div0_id] || 'DIV01'
        div0_node['TYPE'] = contentstructure[:div0_type] || "image"
        div0_node['LABEL'] = contentstructure[:div0_label] || "Images"
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