require "fedora-migrate"
require "dul_hydra/migration"
require "rdf/vocab"

FedoraMigrate::ObjectMover.class_eval do
  def id_component
    nil
  end
end
