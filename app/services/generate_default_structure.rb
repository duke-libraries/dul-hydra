class GenerateDefaultStructure

  attr_reader :object, :overwrite_provided

  def initialize(repo_id, opts={})
    @object = ActiveFedora::Base.find(repo_id)
    @overwrite_provided = opts.with_indifferent_access.fetch(:overwrite_provided, false)
  end

  def process
    raise ArgumentError, "#{@object.id} cannot have structural metadata." unless object.can_have_struct_metadata?
    if object.has_struct_metadata?
      unless object.structure.repository_maintained? || overwrite_provided
        raise ArgumentError, "#{@object.id} has externally provided structural metadata; override option required."
      end
    end
    set_structure_to_default
  end

  private

  def set_structure_to_default
    structure = object.default_structure
    object.structMetadata.content = structure.to_xml
    object.save!
  end

end
