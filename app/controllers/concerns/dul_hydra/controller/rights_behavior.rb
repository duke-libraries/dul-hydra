module DulHydra
  module Controller
    module RightsBehavior
      extend ActiveSupport::Concern

      def permissions
        if request.patch?
          new_permissions = {"group" => {}, "person" => {}}
          all_permissions.each do |access|
            params[:permissions].fetch(access, []).each do |grantee|
              type, name = grantee.split(":", 2)
              type = "person" if type == "user"
              new_permissions[type][name] = access
            end
          end
          current_object.rightsMetadata.clear_permissions!
          current_object.rightsMetadata.permissions = new_permissions
          current_object.license = params[:license]
          if current_object.save
            notify_update(summary: "Rights updated")
            flash[:success] = I18n.t('dul_hydra.rights.alerts.changed')
            redirect_to(action: "show", tab: "permissions") and return
          end
        end        
      end

      protected

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
