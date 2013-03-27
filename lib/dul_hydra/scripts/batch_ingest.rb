module DulHydra::Scripts
  module BatchIngest
    include DulHydra::Scripts::Helpers::BatchIngestHelper
    def self.prep_for_ingest(ingest_manifest)
      manifest = load_yaml(ingest_manifest)
      basepath = manifest[:basepath]
      log = config_logger("preparation", basepath)
      log.info "=================="
      log.info "Ingest Preparation"
      log.info "DulHydra version #{DulHydra::VERSION}"
      log.info "Manifest: #{ingest_manifest}"
      master_source = manifest[:mastersource] || :objects
      unless master_source == PROVIDED
        master = master_document(master_path(manifest[:master], manifest[:basepath]))
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
      object_count = 0;
      for object in manifest[:objects]
        key_identifier = key_identifier(object)
        log.info "Processing #{key_identifier}"
        if master_source == :objects
          master = add_manifest_object_to_master(master, object, manifest[:model])
        end
        qdcsource = object[:qdcsource] || manifest[:qdcsource]
        qdc = case
        when qdcsource && QDC_GENERATION_SOURCES.include?(qdcsource.to_sym)
          generate_qdc(object, qdcsource, basepath)
        else
          stub_qdc()
        end
        result_xml_path = "#{basepath}qdc/#{key_identifier(object)}.xml"
        File.open(result_xml_path, 'w') { |f| qdc.write_xml_to f }
        object_count += 1
      end
      unless master_source == PROVIDED
        File.open(master_path(manifest[:master], manifest[:basepath]), "w") { |f| master.write_xml_to f }
      end
      log.info "Processed #{object_count} object(s)"
      log.info "=================="
    end
    def self.ingest(ingest_manifest)
      manifest = load_yaml(ingest_manifest)
      log = config_logger("ingest", manifest[:basepath])
      log.info "=================="
      log.info "Batch Ingest"
      log.info "DulHydra version #{DulHydra::VERSION}"
      log.info "Manifest: #{ingest_manifest}"
      event_details_header = "Batch ingest\n"
      event_details_header << "DulHydra version #{DulHydra::VERSION}\n"
      event_details_header << "Manifest: #{ingest_manifest}\n"
      manifest_apo = AdminPolicy.find(manifest[:adminpolicy]) unless manifest[:adminpolicy].blank?
      manifest_metadata = manifest[:metadata] unless manifest[:metadata].blank?
      master = File.open(master_path(manifest[:master], manifest[:basepath])) { |f| Nokogiri::XML(f) }
      object_count = 0;
      for object in manifest[:objects]
        event_details = String.new(event_details_header)
        model = object[:model] || manifest[:model]
        if model.blank?
          raise "Missing model"
        end
        ingest_object = model.constantize.new
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
          ingest_object.creator = content_spec[:creator]
          ingest_object.source = case
          when content_spec[:pathroot].blank?
            filename.split("#{File::SEPARATOR}").last
          else
            pathindex = filename.index(content_spec[:pathroot])
            filename.slice(pathindex, filename.length - pathindex)
          end
          ingest_object.save
          ingest_object.generate_thumbnail!
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
        collectionid = object[:collectionid] || manifest[:collectionid]
        if !collectionid.blank?
          ingest_object = set_collection(ingest_object, :id, collectionid)
          event_details << "Collection id: #{collectionid}\n"
        end
        ingest_object.save
        master = add_pid_to_master(master, key_identifier(object), ingest_object.pid)
        write_preservation_event(ingest_object, PreservationEvent::INGESTION, PreservationEvent::SUCCESS, event_details)
        log.info "Ingested #{model} #{key_identifier(object)} into #{ingest_object.pid}"
        object_count += 1
      end
      File.open(master_path(manifest[:master], manifest[:basepath]), "w") { |f| master.write_xml_to f }
      log.info "Ingested #{object_count} object(s)"
      log.info "=================="
    end
    def self.post_process_ingest(ingest_manifest)
      manifest = load_yaml(ingest_manifest)
      log = config_logger("postprocess", manifest[:basepath])
      log.info "=================="
      log.info "Ingest Post-Processing"
      log.info "DulHydra version #{DulHydra::VERSION}"
      log.info "Manifest: #{ingest_manifest}"
      object_count = 0
      master = File.open(master_path(manifest[:master], manifest[:basepath])) { |f| Nokogiri::XML(f) }
      if !manifest[:contentstructure].blank?
        manifest_items = manifest[:objects]
        manifest_items.each do |manifest_item|
          object_count += 1
          identifier = key_identifier(manifest_item)
          repository_object = ActiveFedora::Base.find(get_pid_from_master(master, identifier), :cast => true)
          if manifest[:contentstructure][:type].eql?(GENERATE)
            content_metadata = create_content_metadata_document(repository_object, manifest[:contentstructure])
            filename = "#{manifest[:basepath]}contentmetadata/#{identifier}.xml"
            File.open(filename, 'w') { |f| content_metadata.write_xml_to f }
          end
          repository_object = add_metadata_content_file(repository_object, manifest_item, "contentmetadata", manifest[:basepath])
          repository_object.save
          log.info "Added contentmetadata datastream for #{identifier} to #{repository_object.pid}"          
        end
      end
      log.info "Post-processed #{object_count} object(s)"
      log.info "=================="
    end
    def self.validate_ingest(ingest_manifest)
      ingest_valid = true
      manifest = load_yaml(ingest_manifest)
      basepath = manifest[:basepath]
      log = config_logger("validation", basepath)
      log.info "=================="
      log.info "Ingest Validation"
      log.info "DulHydra version #{DulHydra::VERSION}"
      log.info "Manifest: #{ingest_manifest}"
      event_details_header = "Validate ingest\n"
      event_details_header << "DulHydra version #{DulHydra::VERSION}\n"
      event_details_header << "Manifest: #{ingest_manifest}\n"
      master = File.open(master_path(manifest[:master], manifest[:basepath])) { |f| Nokogiri::XML(f) }
      checksum_spec = manifest[:checksum]
      if !checksum_spec.blank?
        checksum_doc = File.open("#{basepath}checksum/#{checksum_spec[:location]}") { |f| Nokogiri::XML(f) }
      end
      objects = manifest[:objects]
      object_count = 0;
      pass_count = 0;
      fail_count = 0;
      objects.each do |object|
        event_details = String.new(event_details_header)
        object_count += 1
        model = object[:model] || manifest[:model]
        repository_object = nil
        pid_in_master = true
        object_exists = true
        datastream_checksums_valid = true
        datastreams_populated = true
        checksum_matches = true
        parent_child_correct = true
        target_collection_correct = true
        event_details << "Identifier(s): "
        case
        when object[:identifier].is_a?(String)
          event_details << "#{object[:identifier]}"
        when object[:identifier].is_a?(Array)
          event_details << "#{object[:identifier].join(",")}"
        end
        event_details << "\n"
        begin
          event_details << "#{VERIFYING}PID found in master file"
          pid = get_pid_from_master(master, key_identifier(object))
          if pid.blank?
            pid_in_master = false
          end
        rescue
          pid_in_master = false
        end
        event_details << (pid_in_master ? PASS : FAIL) << "\n"
        if !pid.blank?
          if model.blank?
            raise "Missing model for #{key_identifier(object)}"
          end
          event_details << "#{VERIFYING}#{model} object found in repository"
          begin
            repository_object = ActiveFedora::Base.find(pid, :cast => true)
            if repository_object.nil? || !repository_object.conforms_to?(model.constantize)
              object_exists = false
            end
          rescue
            object_exists = false
          end
          event_details << (object_exists ? PASS : FAIL) << "\n"
          if object_exists
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
            expected_datastreams.flatten.each do |datastream|
              event_details << "#{VERIFYING}#{datastream} datastream present and not empty"
              datastream_populated = validate_datastream_populated(datastream, repository_object)
              event_details << (datastream_populated ? PASS : FAIL) << "\n"
              if !datastream_populated
                datastreams_populated = false
              end
            end
            datastreams = repository_object.datastreams.values
            datastreams.each do |datastream|
              profile = datastream.profile(:validateChecksum => true)
              if !profile.empty?
                event_details << "#{VERIFYING}#{datastream.dsid} datastream internal checksum"
                if datastream.dsid == "content"
                  preservation_event = PreservationEvent.validate_checksum!(repository_object, datastream.dsid)
                  event_details << (preservation_event.event_outcome == PreservationEvent::SUCCESS ? PASS : FAIL) << "\n"
                else
                  event_details << (profile["dsChecksumValid"] ? PASS : FAIL) << "\n"
                  if  !profile["dsChecksumValid"]
                    datastream_checksums_valid = false
                  end
                end
              end
            end
            if !checksum_doc.nil?
              event_details << "#{VERIFYING}content datastream external checksum"
              checksum_matches = verify_checksum(repository_object, key_identifier(object), checksum_doc)
              event_details << (checksum_matches ? PASS : FAIL) << "\n"
            end
            parentid = object[:parentid] || manifest[:parentid]
            if parentid.blank?
              if !manifest[:autoparentidlength].blank?
                parentid = key_identifier(object).slice(0, manifest[:autoparentidlength])
              end
            end
            if !parentid.blank?
              event_details << "#{VERIFYING}child relationship to identifier #{parentid}"
              parent = repository_object.parent
              if parent.nil? || !parent.identifier.include?(parentid)
                parent_child_correct = false
              end
              event_details << (parent_child_correct ? PASS : FAIL) << "\n"
            end
            if (model == "Target")
              collectionid = object[:collectionid] || manifest[:collectionid]
              if !collectionid.blank?
                event_details << "#{VERIFYING}target relationship to collection #{collectionid}"
                collection = repository_object.collection
                if collection.nil? || !collection.identifier.include?(collectionid)
                  target_collection_correct = false
                end
                event_details << (target_collection_correct ? PASS : FAIL) << "\n"
              end
            end
          end
        end
        object_valid = pid_in_master && object_exists && datastream_checksums_valid && datastreams_populated \
          && checksum_matches && parent_child_correct && target_collection_correct
        event_details << "Object ingest..." << (object_valid ? "VALIDATES" : "DOES NOT VALIDATE")
        if !object_valid
          ingest_valid = false
        end
        if !repository_object.nil?
          outcome = object_valid ? PreservationEvent::SUCCESS : PreservationEvent::FAILURE
          write_preservation_event(repository_object, PreservationEvent::VALIDATION, outcome, event_details)
        end
        log.info "Validated #{model} #{key_identifier(object)} in #{pid_in_master ? pid : nil}#{object_valid ? PASS : FAIL}"
        object_valid ? pass_count += 1 : fail_count += 1
      end
      log.info "Validated #{object_count} object(s)"
      log.info "PASS: #{pass_count}"
      log.info "FAIL: #{fail_count}"
      log.info "Validation #{ingest_valid ? PASS : FAIL}"
      log.info "=================="
      return ingest_valid
    end
  end
end