module MetsFoldersHelper

  def mets_folder_excluded_file_list
    display = "<ul>"
    @inspection_results.exclusions.each do |exc|
      display << content_tag(:li, exc)
    end
    display << "</ul>"
    display.html_safe
  end

  def mets_folder_message_list(messages)
    display = ""
    messages.each do |msg|
      display << content_tag(:li, strip_path(msg))
    end
    display.html_safe
  end

  private

  def strip_path(message)
    message.gsub("#{@mets_folder.full_path}/", '')
  end

end
