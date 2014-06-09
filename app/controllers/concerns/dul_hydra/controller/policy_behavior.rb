module DulHydra
  module Controller
    module PolicyBehavior
      extend ActiveSupport::Concern

      included do
        require_edit_permission! only: :default_permissions
        self.log_actions << :default_permissions
      end
     
      def default_permissions
        if request.patch?
          new_permissions = {"group" => {}, "person" => {}}
          all_permissions.each do |access|
            params[:permissions].fetch(access, []).each do |grantee|
              type, name = grantee.split(":", 2)
              type = "person" if type == "user"
              new_permissions[type][name] = access
            end
          end
          current_object.defaultRights.clear_permissions!
          current_object.defaultRights.permissions = new_permissions
          current_object.default_license = params[:license]
          if current_object.save
            flash[:success] = I18n.t('dul_hydra.admin_policies.messages.changed')
            redirect_to action: "show", tab: "default_permissions"
          end
        end        
      end

      protected

      def tab_default_permissions
        Tab.new("default_permissions",
                actions: [
                          TabAction.new("edit", 
                                        url_for(action: "default_permissions"),
                                        can?(:edit, current_object)),
                          TabAction.new("download",
                                        datastream_download_url_for("defaultRights"),
                                        show_ds_download_link?(current_object.defaultRights))
                         ]
                )
      end
 
    end
  end
end
