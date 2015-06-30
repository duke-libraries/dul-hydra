module DulHydra
  class BatchAbilityDefinitions < Ddr::Auth::AbilityDefinitions

    def call
      if authenticated?
        can :manage, DulHydra::Batch::Models::Batch, user_id: user.id
      end
      can :manage, DulHydra::Batch::Models::BatchObject do |batch_object|
        can? :manage, batch_object.batch
      end
    end

  end
end
