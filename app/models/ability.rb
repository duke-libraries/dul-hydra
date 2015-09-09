class Ability < Ddr::Auth::Ability

  self.ability_definitions += [ DulHydra::AliasAbilityDefinitions,
                                Ddr::Batch::BatchAbilityDefinitions,
                                DulHydra::ExportSetAbilityDefinitions,
                                DulHydra::MetadataFileAbilityDefinitions,
                                DulHydra::IngestFolderAbilityDefinitions,
                              ]

end
