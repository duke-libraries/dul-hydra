require 'fedora-migrate'

# Wrap source.content in StringIO object to handle files greater than 2 GB in size.
# Cf. https://github.com/projecthydra-labs/fedora-migrate/issues/59
FedoraMigrate::ContentMover.class_eval do
  def move_content
    str_io = StringIO.new(source.content)
    target.original_name = source.label.try(:gsub, /"/, '\"')
    if source.mimeType == "text/csv"
      target.mime_type = source.mimeType + "; charset=#{str_io.read.encoding.to_s}"
      str_io.rewind
    else
      target.mime_type = source.mimeType
    end
    target.content = str_io
    save
    report.error = "Failed checksum" unless valid?
  end
end

FedoraMigrate::TargetConstructor.class_eval do
  def build
    target.new
  end
end

FedoraMigrate::RelsExtDatastreamMover.class_eval do

  def post_initialize
    @target ||= DulHydra::Migration::MigratedObjectFinder.find(source.pid)
    if @target.nil?
      raise FedoraMigrate::Errors::MigrationError, "Target object was not found in Fedora 4. Did you migrate it?"
    end
  end

  def migrate_object(fc3_uri)
    RDF::URI.new(ActiveFedora::Base.id_to_uri(DulHydra::Migration::MigratedObjectFinder.find(fc3_uri).id))
  end

  def missing_object?(statement)
    return false unless DulHydra::Migration::MigratedObjectFinder.find(statement.object).nil?
    raise FedoraMigrate::Errors::MigrationError,
          "could not migrate relationship #{statement.predicate} because #{statement.object} doesn't exist in Fedora 4"
  end

end
