module DulHydra
  class StructureAbilityDefinitions < Ddr::Auth::AbilityDefinitions

    def call
      can :generate_structure, Ddr::Models::Base do |obj|
        obj.can_have_struct_metadata? &&
            (obj.structure.nil? || obj.structure.repository_maintained?) &&
            can?(:update, obj)
      end
    end

  end
end
