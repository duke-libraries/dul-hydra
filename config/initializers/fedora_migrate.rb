require "fedora-migrate"
require "dul_hydra/migration"
require "rdf/vocab"

FedoraMigrate::Hooks.module_eval do
  include DulHydra::Migration::Hooks
end

[ Component, Attachment, Target ].each do |model|
  model.class_eval do
    property :legacy_original_filename,
             predicate: RDF::Vocab::PREMIS.hasOriginalName,
             multiple: false
  end
end

FedoraMigrate::ObjectMover.class_eval do

  def id_component
    nil
  end

end