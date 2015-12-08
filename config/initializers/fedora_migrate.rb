require "fedora-migrate"
require "dul_hydra/fcrepo3/admin_metadata"

FedoraMigrate::Hooks.module_eval do

  def before_rdf_datastream_migration
    if source.dsid == "adminMetadata"
      DulHydra::Fcrepo3::AdminMetadata.convert!(source)
    end
  end

end

FedoraMigrate::ObjectMover.class_eval do

  def id_component
    nil
  end

end