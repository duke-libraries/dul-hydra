require 'fedora-migrate'

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
