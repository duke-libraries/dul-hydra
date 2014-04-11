module DulHydra
  module Controller
    module PolicyBehavior
      extend ActiveSupport::Concern
     
      included do
        require_edit_permission! only: :default_permissions
        self.log_actions << :default_permissions
        self.tabs << :tab_default_permissions
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
            flash[:success] = "Policy successfully changed."
            redirect_to action: "show", tab: "default_permissions"
          end
        end        
      end
 
    end
  end
end