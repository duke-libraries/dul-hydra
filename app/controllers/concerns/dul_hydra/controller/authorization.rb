module DulHydra
  module Controller
    module Authorization
      extend ActiveSupport::Concern

      module ClassMethods
        def require_permission! permission, opts={}
          # if permission == :read
          #   before_action :enforce_show_permissions, opts
          # else
            object = opts.delete(:object) || :current_object
            before_action opts do |controller|
              controller.authorize! permission, controller.send(object)
            end
          # end
        end

        def require_edit_permission! opts={}
          require_permission! :edit, opts
        end

        def require_read_permission! opts={}
          require_permission! :read, opts
        end
      end

    end
  end
end
