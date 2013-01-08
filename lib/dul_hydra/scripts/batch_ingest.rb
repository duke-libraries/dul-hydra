module DulHydra::Scripts
  module BatchIngest
    include DulHydra::Scripts::Helpers::BatchIngestHelper
    def self.prep_for_ingest(ingest_manifest)
      manifest = load_yaml(ingest_manifest)
      basepath = manifest[:basepath]
      master_source = manifest[:mastersource] || :objects
      unless master_source == PROVIDED
        master = create_master_document()
      end
      for entry in manifest[:expand]
        source_doc_path = case
        when entry[:source].start_with?("/")
          entry[:source]
        else
          "#{basepath}#{entry[:type]}/#{entry[:source]}"
        end
        source_doc = File.open(source_doc_path) { |f| Nokogiri::XML(f) }
        expansion = expand(source_doc, entry[:xpath], entry[:idelement])
        expansion.each { | key, value |
          target_path = entry[:targetpath] || "#{basepath}#{entry[:type]}/"
          File.open("#{target_path}#{key}.xml", 'w') { |f| value.write_xml_to f }
        }
      end
      for object in manifest[:objects]
        qdcsource = object[:qdcsource] || manifest[:qdcsource]
        key_identifier = key_identifier(object)
        if master_source == :objects
          master = add_manifest_object_to_master(master, object, manifest[:model])
        end
        qdc = case
        when qdcsource && QDC_GENERATION_SOURCES.include?(qdcsource.to_sym)
          generate_qdc(object, qdcsource, basepath)
        else
          stub_qdc(object, basepath)
        end
        result_xml_path = "#{basepath}qdc/#{key_identifier(object)}.xml"
        File.open(result_xml_path, 'w') { |f| qdc.write_xml_to f }        
      end
      unless master_source == PROVIDED
        File.open(master_path(manifest), "w") { |f| master.write_xml_to f }
      end
    end
    def self.ingest(ingest_manifest)
      manifest = load_yaml(ingest_manifest)
      manifest_apo = AdminPolicy.find(manifest[:adminpolicy]) unless manifest[:adminpolicy].blank?
      manifest_metadata = manifest[:metadata] unless manifest[:metadata].blank?
      master = File.open(master_path(manifest)) { |f| Nokogiri::XML(f) }
      for object in manifest[:objects]
        model = object[:model] || manifest[:model]
        if model.blank?
          raise "Missing model"
        end
        ingest_object = case model
        when "afmodel:Collection" then Collection.new
        when "afmodel:Item" then Item.new
        when "afmodel:Component" then Component.new
        else raise "Invalid model"
        end
        ingest_object.label = object[:label] || manifest[:label]
        ingest_object.admin_policy = object_apo(object, manifest_apo) unless object_apo(object, manifest_apo).nil?
        ingest_object.save
        metadata = object_metadata(object, manifest[:metadata])
        if object_metadata(object, manifest_metadata).include?("qdc")
          qdc = File.open("#{manifest[:basepath]}qdc/#{key_identifier(object)}.xml") { |f| f.read }
          ingest_object.descMetadata.content = qdc
          ingest_object.descMetadata.dsLabel = "Descriptive Metadata for this object"
          ingest_object.identifier = merge_identifiers(object[:identifier], ingest_object.identifier)
        end
        ["contentdm", "digitizationguide", "dpcmetadata", "fmpexport", "jhove", "marcxml", "tripodmets"].each do |metadata_type|
          if object_metadata(object, manifest_metadata).include?(metadata_type)
            ingest_object = add_metadata_content_file(ingest_object, object, metadata_type, manifest[:basepath])
          end
        end
        parentid = object[:parentid] || manifest[:parentid]
        if !parentid.blank?
          ingest_object = set_parent(ingest_object, model, :id, parentid)
        end        
        ingest_object.save
        master = add_pid_to_master(master, key_identifier(object), ingest_object.pid)
      end
      File.open(master_path(manifest), "w") { |f| master.write_xml_to f }
    end
  end
end