module IngestFoldersHelper
  
  def ingest_folder_create_link
    link_to I18n.t('batch.ingest_folder.create'), new_ingest_folder_path
  end
  
  def object_display_title(pid)
    if pid.present?
      begin
        object = ActiveFedora::Base.find(pid, :cast => true)
        if object.respond_to?(:title_display)
          object.title_display
        end
      rescue ActiveFedora::ObjectNotFoundError
        log.error("Unable to find #{pid} in repository")
      end
    end
  end
  
  def permitted_folder_bases
    IngestFolder.permitted_folders(current_user)
  end
  
  def excluded_file_list
    display = ""
		@scan_results.excluded_files.each do |exc|
			display << content_tag(:li, exc)
		end
		display.html_safe
  end
  
  def file_count
    pluralize(@scan_results.file_count, @ingest_folder.model)
  end
  
  def file_creator
    IngestFolder.file_creators.fetch(@ingest_folder.file_creator, nil)
  end
  
  def parent_count
    pluralize(@scan_results.parent_count, parent_model)
  end
  
  def parent_model
    DulHydra::Utils.reflection_object_class(DulHydra::Utils.relationship_object_reflection(@ingest_folder.model, "parent")).name
  end
  
  def target_count
    pluralize(@scan_results.target_count, IngestFolder.default_target_model)
  end
  
end