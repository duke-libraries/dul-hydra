module DulHydra::Utils

  DEFAULT_MIME_TYPE = "application/octet-stream"

  # Return a mime type for the file, using the file_name if necessary
  # file can be a File object or file path (String)
  # Return default mime type if unable to determine otherwise
  def self.mime_type_for(file, file_name=nil)
    return file.content_type if file.respond_to?(:content_type) # E.g., Rails uploaded file
    path = file_name || file_path(file) rescue nil
    mime_types = MIME::Types.of(path) rescue []                 # MIME::Types.of blows up on nil
    mime_types.empty? ? DEFAULT_MIME_TYPE : mime_types.first.content_type
  end

  def self.file_or_path? file
    file_path(file)
  rescue ArgumentError
    false
  end
  
  def self.file_path? file
    # length is a sanity check
    file.is_a?(String) && (file.length < 1024) && File.exists?(file)
  end

  def self.file_path file
    if file.respond_to?(:path) 
      File.absolute_path(file.path)
    elsif file_path?(file)
      file
    else
      raise ArgumentError, "File argument is neither a File nor a path to an existing file."
    end
  end

  def self.file_name_for file
    return file.original_filename if file.respond_to?(:original_filename) && file.original_filename.present?
    File.basename(file_path(file)) rescue nil
  end

  def self.file_uri?(uri)
    return false unless uri
    URI.parse(uri).scheme == "file"
  end

  # Return file path for URI string 
  # Should reverse .path_to_uri
  # "file:/path/to/file" => "/path/to/file"
  def self.path_from_uri(uri)
    URI.unescape(URI.parse(uri).path)
  end

  # Return URI string for file path
  # Should reverse .path_from_uri
  # "/path/to/file" => "file:/path/to/file"
  def self.path_to_uri(path)
    uri = URI.parse(URI.escape(path))
    uri.scheme = "file"
    uri.to_s
  end

  def self.ds_as_of_date_time(ds)
    ds.dsCreateDate.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
  end
  
  # Find an object with a given identifier and return its PID.
  # Returns the PID if a single object is found.
  # Returns nil if no object is found.
  # Raises DulHydra::Error if more than one object is found.
  # Options can be provided to limit the scope of matching objects
  #   model: Will only consider objects of that model
  #   collection: Will only consider objects that either are that collection or which are
  #      direct children of that collection (i.e., effectively searches a collection and its
  #      items for an object with the given identifier)
  def self.pid_for_identifier(identifier, opts={})
    model = opts.fetch(:model, nil)
    collection = opts.fetch(:collection, nil)
    objs = []
    ActiveFedora::Base.find_each( { DulHydra::IndexFields::IDENTIFIER => identifier }, { :cast => true } ) { |o| objs << o }
    pids = []
    objs.each { |obj| pids << obj.pid }
    if model.present?
      objs.each { |obj| pids.delete(obj.pid) unless obj.is_a?(model.constantize) }
    end
    if collection.present?
      objs.each do |obj|
        pids.delete(obj.pid) unless obj == collection || obj.parent == collection
      end
    end
    case pids.size
    when 0
      nil
    when 1
      pids.first
    else
      raise DulHydra::Error, I18n.t('dul_hydra.errors.multiple_object_matches', :criteria => "identifier #{identifier}")
    end
  end

  # Returns the reflection object for a given model name and relationship name
  # E.g., relationship_object_reflection("Item", "parent") returns the reflection object for
  # an Item's parent relationship.  This reflection object can then be used to obtain the
  # class of the relationship object using the reflection_object_class(reflection) method below.
  def self.relationship_object_reflection(model, relationship_name)
    reflection = nil
    if model
      begin
        reflections = model.constantize.reflections
      rescue NameError
        # nothing to do here except that we can't return the appropriate reflection
      else
        reflections.each do |reflect|
          if reflect[0].eql?(relationship_name.to_sym)
            reflection = reflect
          end
        end
      end
    end
    return reflection
  end

  # Returns the class associated with the :class_name attribute in the options of a reflection
  # E.g., reflection_object_class(relationship_object_reflection("Item", "parent")) returns the
  # Collection class.
  def self.reflection_object_class(reflection)
    reflection_object_model = nil
    klass = nil
    if reflection[1].options[:class_name]
      reflection_object_model = reflection[1].options[:class_name]
    else
      reflection_object_model = ActiveSupport::Inflector.camelize(reflection[0])
    end
    if reflection_object_model
      begin
        klass = reflection_object_model.constantize
      rescue NameError
        # nothing to do here except that we can't return the reflection object class
      end
    end
    return klass
  end
  
end
