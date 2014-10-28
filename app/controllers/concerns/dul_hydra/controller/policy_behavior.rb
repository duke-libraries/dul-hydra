module DulHydra
  module Controller
    module PolicyBehavior
      extend ActiveSupport::Concern
     
      def default_permissions
        if request.patch?
          new_permissions = {"group" => {}, "person" => {}}
          default_permissions_params.each do |access, grantees|
            grantees.each do |grantee|
              type, name = grantee.split(":", 2)
              type = "person" if type == "user"
              new_permissions[type][name] = access.to_s
            end
          end
          current_object.defaultRights.clear_permissions!
          current_object.defaultRights.permissions = new_permissions
          current_object.default_license = params[:license]
          if current_object.save
            notify_update(summary: "Default rights updated")
            flash[:success] = I18n.t('dul_hydra.admin_policies.messages.changed')
            redirect_to(action: "show", tab: "default_permissions") and return
          end
        end        
      end

      protected

      def default_permissions_params
        permitted = all_permissions.each_with_object({}) {|p, memo| memo[p] = []}
        params.require(:permissions).permit(permitted)
      end

      def tab_default_permissions
        Tab.new("default_permissions",
                actions: [
                          TabAction.new("edit", 
                                        url_for(action: "default_permissions"),
                                        can?(:default_permissions, current_object)),
                          TabAction.new("download",
                                        download_path(current_object, "defaultRights"),
                                        show_ds_download_link?(current_object.defaultRights))
                         ]
                )
      end
 
    end
  end
end
