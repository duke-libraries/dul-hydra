class Ability < Ddr::Auth::Ability

  self.ability_definitions += [ DulHydra::AliasAbilityDefinitions,
                                DulHydra::BatchAbilityDefinitions,
                                DulHydra::MetadataFileAbilityDefinitions,
                                DulHydra::IngestFolderAbilityDefinitions,
                                DulHydra::NestedFolderIngestAbilityDefinitions,
                                DulHydra::StandardIngestAbilityDefinitions,
                                DulHydra::StructureAbilityDefinitions,
                              ]

end
