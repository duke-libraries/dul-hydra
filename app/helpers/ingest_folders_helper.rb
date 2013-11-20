module IngestFoldersHelper
  
  def ingest_folder_create_link
    button_to I18n.t('batch.ingest_folder.create'), new_ingest_folder_path, :method => 'get'
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