module DulHydra::Batch::Models

  # This is a superclass containing methods common to all batch object objects.  It is not intended to be instantiated directly.
  # This superclass and its subclasses are designed following the ActiveRecord single-table inheritance pattern.
  class BatchObject < ActiveRecord::Base

    belongs_to :batch, inverse_of: :batch_objects
    has_many :batch_object_attributes, -> { order "id ASC" }, inverse_of: :batch_object, dependent: :destroy
    has_many :batch_object_datastreams, inverse_of: :batch_object, dependent: :destroy
    has_many :batch_object_relationships, inverse_of: :batch_object, dependent: :destroy

    VERIFICATION_PASS = "PASS"
    VERIFICATION_FAIL = "FAIL"

    EVENT_SUMMARY = <<-EOS
%{label}
Batch object database id: %{batch_id}
Batch object identifier: %{identifier}
Model: %{model}
    EOS

    def self.pid_from_identifier(identifier, batch_id)
      query = "identifier = :identifier"
      query << " and batch_id = :batch_id" if batch_id
      params = { :identifier => identifier }
      params[:batch_id] = batch_id if batch_id
      sort = "updated_at asc"
      found_objects = DulHydra::Batch::Models::BatchObject.where(query, params).order(sort)
      pids = []
      found_objects.each { |obj| pids << obj.pid }
      return pids
    end

    def validate
      @error_prefix = I18n.t('batch.manifest_object.errors.prefix', :identifier => identifier, :id => id)
      errors = []
      errors += validate_model if model
      errors += validate_datastreams if batch_object_datastreams
      errors += validate_relationships if batch_object_relationships
      errors += local_validations
      return errors
    end

    def local_validations
      []
    end

    def model_datastream_keys
      raise NotImplementedError
    end

    def process(user, opts = {})
      raise NotImplementedError
    end

    def results_message
      raise NotImplementedError
    end

    Results = Struct.new(:repository_object, :verified, :verifications)

    private

    def validate_model
      errs = []
      begin
        model.constantize
      rescue NameError
        errs << "#{@error_prefix} Invalid model name: #{model}"
      end
      return errs
    end

    def validate_datastreams
      errs = []
      batch_object_datastreams.each do |d|
        if model_datastream_keys.present?
          unless model_datastream_keys.include?(d.name)
            errs << "#{@error_prefix} Invalid datastream name for #{model}: #{d.name}"
          end
        end
        unless DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPES.include?(d.payload_type)
          errs << "#{@error_prefix} Invalid payload type for #{d.name} datastream: #{d.payload_type}"
        end
        if d.payload_type.eql?(DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME)
          unless File.readable?(d.payload)
            errs << "#{@error_prefix} Missing or unreadable file for #{d[:name]} datastream: #{d[:payload]}"
          end
        end
        if d.checksum && !d.checksum_type
          errs << "#{@error_prefix} Must specify checksum type if providing checksum for #{d.name} datastream"
        end
        if d.checksum_type
          unless Ddr::Datastreams::CHECKSUM_TYPES.include?(d.checksum_type)
            errs << "#{@error_prefix} Invalid checksum type for #{d.name} datastream: #{d.checksum_type}"
          end
        end
      end
      return errs
    end

    def validate_relationships
      errs = []
      batch_object_relationships.each do |r|
        obj_model = nil
        unless DulHydra::Batch::Models::BatchObjectRelationship::OBJECT_TYPES.include?(r[:object_type])
          errs << "#{@error_prefix} Invalid object_type for #{r[:name]} relationship: #{r[:object_type]}"
        end
        if r[:object_type].eql?(DulHydra::Batch::Models::BatchObjectRelationship::OBJECT_TYPE_PID)
          if batch.present? && batch.found_pids.keys.include?(r[:object])
            obj_model = batch.found_pids[r[:object]]
          else
            begin
              obj = ActiveFedora::Base.find(r[:object], :cast => true)
              obj_model = obj.class.name
              if batch.present?
                batch.add_found_pid(obj.pid, obj_model)
              end
            rescue ActiveFedora::ObjectNotFoundError
              pid_in_batch = false
              if batch.present?
                if batch.pre_assigned_pids.include?(r[:object])
                  pid_in_batch = true
                end
              end
              unless pid_in_batch
                errs << "#{@error_prefix} #{r[:name]} relationship object does not exist: #{r[:object]}"
              end
            end
          end
          if obj_model
            relationship_reflection = Ddr::Utils.relationship_object_reflection(model, r[:name])
            if relationship_reflection
              klass = Ddr::Utils.reflection_object_class(relationship_reflection)
              if klass
                errs << "#{@error_prefix} #{r[:name]} relationship object #{r[:object]} exists but is not a(n) #{klass}" unless batch.found_pids[r[:object]].eql?(klass.name)
              end
            else
              errs << "#{@error_prefix} #{model} does not define a(n) #{r[:name]} relationship"
            end
          end
        end
      end
      return errs
    end

    def verify_repository_object
      verifications = {}
      begin
        repo_object = ActiveFedora::Base.find(pid, :cast => true)
      rescue ActiveFedora::ObjectNotFound
        verifications["Object exists in repository"] = VERIFICATION_FAIL
      else
        verifications["Object exists in repository"] = VERIFICATION_PASS
        verifications["Object is correct model"] = verify_model(repo_object) if model
        verifications["Object has correct label"] = verify_label(repo_object) if label
        unless batch_object_attributes.empty?
          batch_object_attributes.each do |a|
            if a.operation == DulHydra::Batch::Models::BatchObjectAttribute::OPERATION_ADD
              verifications["#{a.name} attribute set correctly"] = verify_attribute(repo_object, a)
            end
          end
        end
        unless batch_object_datastreams.empty?
          batch_object_datastreams.each do |d|
            verifications["#{d.name} datastream present and not empty"] = verify_datastream(repo_object, d)
            verifications["#{d.name} external checksum match"] = verify_datastream_external_checksum(repo_object, d) if d.checksum
          end
        end
        unless batch_object_relationships.empty?
          batch_object_relationships.each do |r|
            verifications["#{r.name} relationship is correct"] = verify_relationship(repo_object, r)
          end
        end
        result = Ddr::Actions::FixityCheck.execute repo_object
        verifications["Fixity check"] = result.success ? VERIFICATION_PASS : VERIFICATION_FAIL
      end
      verifications
    end

    def verify_model(repo_object)
      begin
        if repo_object.class.eql?(model.constantize)
          return VERIFICATION_PASS
        else
          return VERIFICATION_FAIL
        end
      rescue NameError
        return VERIFICATION_FAIL
      end
    end

    def verify_label(repo_object)
      repo_object.label.eql?(label) ? VERIFICATION_PASS : VERIFICATION_FAIL
    end

    def verify_attribute(repo_object, attribute)
      repo_object.datastreams[attribute.datastream].values(attribute.name).include?(attribute.value) ?
              VERIFICATION_PASS : VERIFICATION_FAIL
    end

    def verify_datastream(repo_object, datastream)
      if repo_object.datastreams.include?(datastream.name) &&
          repo_object.datastreams[datastream.name].has_content?
        VERIFICATION_PASS
      else
        VERIFICATION_FAIL
      end
    end

    def verify_datastream_external_checksum(repo_object, datastream)
      repo_object.datastreams[datastream.name].validate_checksum! datastream.checksum, datastream.checksum_type
      return VERIFICATION_PASS
    rescue Ddr::Models::ChecksumInvalid
      return VERIFICATION_FAIL
    end

    def verify_relationship(repo_object, relationship)
      relationship_reflection = Ddr::Utils.relationship_object_reflection(model, relationship.name)
      relationship_object_class = Ddr::Utils.reflection_object_class(relationship_reflection)
      relationship_object = repo_object.send(relationship.name)
      if !relationship_object.nil? &&
          relationship_object.pid.eql?(relationship.object) &&
          relationship_object.is_a?(relationship_object_class)
        VERIFICATION_PASS
      else
        VERIFICATION_FAIL
      end
    end

    def add_attribute(repo_object, attribute)
      repo_object.datastreams[attribute.datastream].add_value(attribute.name, attribute.value)
      return repo_object
    end

    def clear_attribute(repo_object, attribute)
      repo_object.datastreams[attribute.datastream].set_values(attribute.name, nil)
      return repo_object
    end

    def clear_attributes(repo_object, attribute)
      repo_object.datastreams[attribute.datastream].class.term_names.each do |term|
        repo_object.datastreams[attribute.datastream].set_values(term, nil) if repo_object.datastreams[attribute.datastream].values(term)
      end
      return repo_object
    end

    def populate_datastream(repo_object, datastream)
      case datastream[:payload_type]
      when DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_BYTES
        ds_content = datastream[:payload]
        if repo_object.datastreams[datastream[:name]].is_a? ActiveFedora::RDFDatastream
          ds_content = set_rdf_subject(repo_object, ds_content)
        end
        repo_object.datastreams[datastream[:name]].content = ds_content
      when DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME
        if repo_object.datastreams[datastream[:name]].is_a? ActiveFedora::RDFDatastream
          ds_content = set_rdf_subject(repo_object, File.read(datastream[:payload]))
          mime_type = "application/n-triples"
        else
          ds_content = File.new(datastream[:payload])
        end
        file_name = File.basename(datastream[:payload])
        dsid = datastream[:name]
        opts = { filename: file_name }
        opts.merge({ mime_type: mime_type }) if mime_type
        repo_object.add_file(ds_content, dsid, opts)
      end
      return repo_object
    end

    def add_relationship(repo_object, relationship)
      relationship_object = case relationship[:object_type]
      when BatchObjectRelationship::OBJECT_TYPE_PID
        ActiveFedora::Base.find(relationship[:object], :cast => true)
      end
      repo_object.send("#{relationship[:name]}=", relationship_object)
      return repo_object
    end

    def set_rdf_subject(repo_object, ds_content)
      graph = RDF::Graph.new
      RDF::Reader.for(:ntriples).new(ds_content) do |reader|
        reader.each_statement do |statement|
          if statement.subject.is_a? RDF::Node
            statement.subject = RDF::URI(repo_object.internal_uri)
          end
          graph.insert(statement)
        end
      end
      graph.dump :ntriples
    end

  end

end
