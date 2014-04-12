module DulHydra
  module Controller
    module RightsBehavior
      extend ActiveSupport::Concern

      included do
        require_edit_permission! only: :permissions
        self.log_actions << :permissions
      end

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
            flash[:success] = "Rights successfully changed."
            redirect_to action: "show", tab: "permissions"
          end
        end        
      end

      protected

      def tab_permissions
        Tab.new("permissions",
                actions: [
                          TabAction.new("edit", 
                                        url_for(action: "permissions"),
                                        can?(:edit, current_object)),
                          TabAction.new("download",
                                        datastream_download_url_for("rightsMetadata"),
                                        show_ds_download_link?(current_object.rightsMetadata))
                         ]
                )
      end

    end
  end
end
