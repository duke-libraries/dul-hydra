module IngestFoldersHelper

  def permitted_ingest_folder_bases
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

  def parent_count
    pluralize(@scan_results.parent_count, parent_model)
  end

  def parent_model
    Ddr::Utils.reflection_object_class(Ddr::Utils.relationship_object_reflection(@ingest_folder.model, "parent")).name
  end

  def target_count
    pluralize(@scan_results.target_count, IngestFolder.default_target_model)
  end

end
