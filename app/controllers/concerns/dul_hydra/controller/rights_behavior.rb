module DulHydra
  module Controller
    module RightsBehavior
      extend ActiveSupport::Concern

      def permissions
        if request.patch?
          set_permissions
          set_license
          if current_object.save
            notify_update(summary: "Rights updated")
            flash[:success] = I18n.t('dul_hydra.rights.alerts.changed')
            redirect_to(action: "show", tab: "permissions") and return
          end
        end
      end

      protected

      def permissions_params
        params.permit(permissions: all_permissions.map { |p| {p => []} },
                      license: ["title", "description", "url"])
      end

      def set_permissions
        current_object.rightsMetadata.clear_permissions!
        current_object.rightsMetadata.permissions = new_permissions
      end

      def set_license
        current_object.license = permissions_params[:license]
      end

      def new_permissions
        form_perms = permissions_params[:permissions] || {}
        all_permissions.each_with_object({}) do |access, perms|
          form_perms.fetch(access, []).each do |grantee|
            type, name = grantee.split(":", 2)
            type = "person" if type == "user"
            perms[type] ||= {}
            perms[type][name] = access
          end
        end
      end

      def tab_permissions
        Tab.new("permissions",
                actions: [
                          TabAction.new("edit",
                                        url_for(action: "permissions"),
                                        can?(:permissions, current_object)),
                          TabAction.new("download",
                                        download_path(current_object, "rightsMetadata"),
                                        show_ds_download_link?(current_object.rightsMetadata))
                         ]
                )
      end

    end
  end
end
