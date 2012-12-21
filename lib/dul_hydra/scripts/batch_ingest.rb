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
      for object in manifest[:objects]
        key_identifier = key_identifier(object)
        if master_source == :objects
          master = add_manifest_object_to_master(master, object, manifest[:model])
        end
        if object[:qdcsource] && QDC_GENERATION_SOURCES.include?(object[:qdcsource].to_sym)
          generate_qdc(object, basepath)
        end
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
        end
        ["contentdm", "digitizationguide", "dpcmetadata", "fmpexport", "jhove", "marcxml"].each do |metadata_type|
          if object_metadata(object, manifest_metadata).include?(metadata_type)
            ingest_object = add_metadata_content_file(ingest_object, object, metadata_type, manifest[:basepath])
          end
        end
        ingest_object.save
        master = add_pid_to_master(master, key_identifier(object), ingest_object.pid)
      end
      File.open(master_path(manifest), "w") { |f| master.write_xml_to f }
    end
  end
end