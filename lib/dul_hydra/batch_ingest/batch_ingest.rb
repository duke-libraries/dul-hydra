module DulHydra::BatchIngest
  class BatchIngest
    
    LOG_CONFIG_FILEPATH = File.join(Rails.root, 'config', 'log4r_batch_ingest.yml')

    BATCH_LOG_HEADER = "Batch Ingest DulHydra version #{DulHydra::VERSION} Batch Size: %{batch_size}"
    
    BATCH_LOG_FOOTER = "Ingested %{ingest_count} of %{batch_size} Object(s)"
    
    INGEST_PRESERVATION_EVENT_DETAIL = <<-EOS
      Batch ingest
      DulHydra version #{DulHydra::VERSION}
      Identifier: %{identifier}
      Model: %{model}
      %{adminpolicy}
      %{data}
      %{parent}
      %{targetfor}
    EOS
    
    def batch(ingest_objects, options={})
      validate_options(options)
      options[:pid_master] ||= File.join(Dir.tmpdir, 'pid_master.xml')
      options[:log_file] ||= File.join(Dir.tmpdir, 'batch_ingest.log')
      log = config_logger(options[:log_file])
      log.info BATCH_LOG_HEADER % { :batch_size => ingest_objects.size }
      ingest_count = 0
      ingest_objects.each do |ingest_object|
        ingested_object = ingest(ingest_object, log)
        ingest_count += 1 if ingested_object && !ingested_object.new?
      end
      log.info BATCH_LOG_FOOTER % { :ingest_count => ingest_count, :batch_size => ingest_objects.size }
    end
    
    def ingest(ingest_object, log=nil)
      validation = ingest_object.validate
      if validation.valid?
        begin
          repo_object = ingest_object.model.constantize.new
          repo_object.label = ingest_object.label if ingest_object.label
          repo_object.admin_policy = AdminPolicy.find(ingest_object.admin_policy, :cast => true) if ingest_object.admin_policy
          ingest_object.data.each {|d| repo_object = add_datastream(repo_object, d)} if ingest_object.data
          repo_object.parent = ActiveFedora::Base.find(ingest_object.parent, :cast => true) if ingest_object.parent
          repo_object.collection = Collection.find(ingest_object.target_for, :cast => true) if ingest_object.target_for
          repo_object.save
        rescue => e
          log_message = "Attempt to ingest #{ingest_object.model} #{ingest_object.identifier} FAILED: #{e.message}"
        else
          log_message = "Ingested #{ingest_object.model} #{ingest_object.identifier} into #{repo_object.pid}"
          create_preservation_event(PreservationEvent::INGESTION, PreservationEvent::SUCCESS, repo_object, ingest_object)
        end
      else
        log_message = "INVALID ingest object #{ingest_object.identifier}:\n#{validation.errors.join('\n')}"
      end
      log.info log_message if log
      return repo_object
    end
    
    private
    
    def add_datastream(repo_object, data)
      case data[:payload_type]
      when "bytes"
        repo_object.datastreams[data[:datastream_name]].content = data[:payload]
      when "filename"
        data_file = File.open(data[:payload])
        repo_object.datastreams[data[:datastream_name]].content_file = data_file
        repo_object.save # save the object to the repository before we close the file 
        data_file.close
      end
      repo_object.generate_thumbnail! if data[:datastream_name].eql?(DulHydra::Datastreams::CONTENT)
      return repo_object
    end
    
    def create_preservation_event(event_type, event_outcome, repository_object, ingest_object)
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
                                    :linking_object_id_value => repository_object.internal_uri,
                                    :event_detail => format_event_details(event_type, ingest_object),
                                    :for_object => repository_object)
      event.save
    end
    
    def format_event_details(event_type, ingest_object)
      event_details = case event_type
      when PreservationEvent::INGESTION
        adminpolicy = "Admin policy: #{ingest_object.admin_policy}" if ingest_object.admin_policy
        if ingest_object.data
          data_list = []
          ingest_object.data.each { |d| data_list << d[:datastream_name] }
          data_names = "Data: #{data_list.join(',')}"
        end
        parent = "Parent: #{ingest_object.parent}" if ingest_object.parent
        targetfor = "Target for: #{ingest_object.target_for}" if ingest_object.target_for
        INGEST_PRESERVATION_EVENT_DETAIL % {
          :identifier => ingest_object.identifier,
          :model => ingest_object.model,
          :adminpolicy => adminpolicy,
          :data => data_names,
          :parent => parent,
          :targetfor => targetfor
        }
      end
    end
    
    def config_logger(filename)
      log_config = YAML.load_file(LOG_CONFIG_FILEPATH)
      YamlConfigurator['filename'] = filename
      loggers = log_config['log4r_config']['loggers']
      outputters = log_config['log4r_config']['outputters']
      this_logger = loggers.detect { |logger| logger['name'].eql?('batch') }
      this_logger_outputter_names = this_logger['outputters']
      this_logger_outputters = outputters.select { |outputter| this_logger_outputter_names.include?(outputter['name']) }
      this_logger_outputters.each do |this_logger_outputter|
        if this_logger_outputter['filename']
          dirname = File.dirname(this_logger_outputter['filename'])
          FileUtils.mkdir_p dirname unless File.exists?(dirname)
        end
      end
      YamlConfigurator.decode_yaml(log_config['log4r_config'])
      return Log4r::Logger['batch']
    end

    def validate_options(options)
      valid_options = [ :pid_master, :log_file ]
      raise Exception.new("Options argument is not a Hash") unless options.is_a? Hash
      options.each_key { |key| raise Exception.new("Invalid option: #{key}") unless valid_options.include?(key) }
    end
  
  end
end