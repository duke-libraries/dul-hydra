class Ability < Ddr::Auth::Ability

  self.ability_definitions += [ DulHydra::AliasAbilityDefinitions,
                                DulHydra::BatchAbilityDefinitions,
                                DulHydra::ExportSetAbilityDefinitions,
                                DulHydra::MetadataFileAbilityDefinitions,
                                DulHydra::IngestFolderAbilityDefinitions,
                                DulHydra::StandardIngestAbilityDefinitions,
                              ]

end
