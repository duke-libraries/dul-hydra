module DulHydra::Reports
  class HasContentFilter < StaticFilter

    self.clauses = [
      "%s:(Component OR Attachment OR Target)" % Ddr::Index::Fields::ACTIVE_FEDORA_MODEL
    ]

  end
end
