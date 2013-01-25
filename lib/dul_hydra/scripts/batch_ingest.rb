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
      if manifest[:split]
        for entry in manifest[:split]
          source_doc_path = case
          when entry[:source].start_with?("/")
            entry[:source]
          else
            "#{basepath}#{entry[:type]}/#{entry[:source]}"
          end
          source_doc = File.open(source_doc_path) { |f| Nokogiri::XML(f) }
          parts = split(source_doc, entry[:xpath], entry[:idelement])
          parts.each { | key, value |
            target_path = entry[:targetpath] || "#{basepath}#{entry[:type]}/"
            File.open("#{target_path}#{key}.xml", 'w') { |f| value.write_xml_to f }
          }
        end
      end
      for object in manifest[:objects]
        key_identifier = key_identifier(object)
        qdcsource = object[:qdcsource] || manifest[:qdcsource]
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
        event_details = "Batch ingest\n"
        event_details << "DulHydra version #{DulHydra::VERSION}\n"
        event_details << "Manifest: #{ingest_manifest}\n"
        model = object[:model] || manifest[:model]
        if model.blank?
          raise "Missing model"
        end
        ingest_object = case model
        when "Collection" then Collection.new
        when "Item" then Item.new
        when "Component" then Component.new
        else raise "Invalid model"
        end
        event_details << "Model: #{model}\n"
        event_details << "Identifier(s): "
        case
        when object[:identifier].is_a?(String)
          event_details << "#{object[:identifier]}\n"
        when object[:identifier].is_a?(Array)
          event_details << "#{object[:identifier].join(",")}\n"
        end
        ingest_object.label = object[:label] || manifest[:label]
        ingest_object.admin_policy = object_apo(object, manifest_apo) unless object_apo(object, manifest_apo).nil?
        ingest_object.save
        metadata = object_metadata(object, manifest[:metadata])
        event_details << "Metadata: #{metadata.join(",")}\n"
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
        content_spec = object[:content] || manifest[:content]
        if !content_spec.blank?
          filename = "#{content_spec[:location]}#{key_identifier(object)}#{content_spec[:extension]}"
          ingest_object = add_content_file(ingest_object, filename)
          event_details << "Content file: #{filename}\n"
        end
        parentid = object[:parentid] || manifest[:parentid]
        if parentid.blank?
          if !manifest[:autoparentidlength].blank?
            parentid = key_identifier(object).slice(0, manifest[:autoparentidlength])
          end
        end
        if !parentid.blank?
          ingest_object = set_parent(ingest_object, model, :id, parentid)
          event_details << "Parent id: #{parentid}\n"
        end
        ingest_object.save
        master = add_pid_to_master(master, key_identifier(object), ingest_object.pid)
        write_ingestion_event(ingest_object, event_details)
      end
      File.open(master_path(manifest), "w") { |f| master.write_xml_to f }
    end
    def self.post_process_ingest(ingest_manifest)
      manifest = load_yaml(ingest_manifest)
      if !manifest[:contentstructure].blank?
        case manifest[:contentstructure][:type]
        when "generate"
          sequence_start = manifest[:contentstructure][:sequencestart]
          sequence_length = manifest[:contentstructure][:sequencelength]
          manifest_items = manifest[:objects]
          manifest_items.each do |manifest_item|
            identifier = key_identifier(manifest_item)
            items = Item.find_by_identifier(identifier)
            case items.size
            when 1
              item = items.first
              content_metadata = create_content_metadata_document(item, sequence_start, sequence_length)
              filename = "#{manifest[:basepath]}contentmetadata/#{identifier}.xml"
              File.open(filename, 'w') { |f| content_metadata.write_xml_to f }
              item = add_metadata_content_file(item, manifest_item, "contentmetadata", manifest[:basepath])
              item.save
            when 0
              raise "Item #{identifier} not found"
            else
              raise "Multiple items #{identifier} found"
            end
          end
        end
      end
    end
    def self.validate_ingest(ingest_manifest)
      pids_in_master = true
      all_objects_exist = true
      datastream_checksums_valid = true
      datastreams_populated = true
      checksums_match = true
      parent_child_correct = true
      manifest = load_yaml(ingest_manifest)
      basepath = manifest[:basepath]
      master = File.open(master_path(manifest)) { |f| Nokogiri::XML(f) }
      checksum_spec = manifest[:checksum]
      if !checksum_spec.blank?
        checksum_doc = File.open("#{basepath}checksum/#{checksum_spec[:location]}") { |f| Nokogiri::XML(f) }
      end
      objects = manifest[:objects]
      objects.each do |object|
        begin
          pid = get_pid_from_master(master, key_identifier(object))
          if pid.blank?
            pids_in_master = false
          end
        rescue
          pids_in_master = false
        end
        if !pid.blank?
          model = object[:model] || manifest[:model]
          if model.blank?
            raise "Missing model for #{key_identifier(object)}"
          end
          if validate_object_exists(model, pid)
            repository_object = ActiveFedora::Base.find(pid, :cast => true)
            datastreams = repository_object.datastreams.values
            datastreams.each do |datastream|
              profile = datastream.profile(:validateChecksum => true)
              if !profile.empty? && !profile["dsChecksumValid"]
                datastream_checksums_valid = false
              end
            end
            metadata = object_metadata(object, manifest[:metadata])
            expected_datastreams = [ "DC", "RELS-EXT" ]
            metadata.each do |m|
              expected_datastreams << datastream_name(m)
            end
            if !object[:content].blank? || !manifest[:content].blank?
              expected_datastreams << datastream_name("content")
            end
            if !object[:contentstructure].blank? || !manifest[:contentstructure].blank?
              expected_datastreams << datastream_name("contentstructure")
            end
            if !validate_populated_datastreams(expected_datastreams.flatten, repository_object)
              datastreams_populated = false
            end
          else
            all_objects_exist = false
          end
          if !checksum_doc.nil?
            checksums_match = verify_checksum(repository_object, key_identifier(object), checksum_doc)
          end
          parentid = object[:parentid] || manifest[:parentid]
          if parentid.blank?
            if !manifest[:autoparentidlength].blank?
              parentid = key_identifier(object).slice(0, manifest[:autoparentidlength])
            end
          end
          if !parentid.blank?
            parent = get_parent(repository_object)
            if parent.nil? || !parent.identifier.include?(parentid)
              parent_child_correct = false
            end
            if parent_child_correct
              children = get_children(parent)
              if children.blank? || !children.include?(repository_object)
                parent_child_correct = false
              end
            end
          end
        end
      end
      return pids_in_master && all_objects_exist && datastream_checksums_valid && datastreams_populated \
              && checksums_match && parent_child_correct
    end
  end
end