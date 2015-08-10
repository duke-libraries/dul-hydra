module DulHydra::Reports
  class HasContentFilter < StaticFilter

    self.clauses = [
      "%s:(Component OR Attachment OR Target)" % Ddr::IndexFields::ACTIVE_FEDORA_MODEL
    ]

  end
end
