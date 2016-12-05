module DulHydra
  class BatchAbilityDefinitions < Ddr::Auth::AbilityDefinitions

    def call
      can :read, [ Ddr::Batch::Batch, Ddr::Batch::BatchObject ] if authenticated?
      can :manage, Ddr::Batch::Batch, user: user
      can :manage, Ddr::Batch::BatchObject do |batch_object|
        batch_object.batch.user == user
      end
    end

  end
end
