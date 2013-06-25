module DulHydra
  autoload :Error, 'dul_hydra/error'

  mattr_accessor :children_sort_fields
  self.children_sort_fields = {
    "#{DulHydra::IndexFields::IDENTIFIER} asc" => "Identifier",
    "#{DulHydra::IndexFields::TITLE} asc" => "Title"
  }
end
