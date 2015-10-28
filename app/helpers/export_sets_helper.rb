module ExportSetsHelper

  def export_set_show_title
    title = "Export Set #{@export_set.id}"
    title << ": #{@export_set.title}" if @export_set.title.present?
    title
  end

  def export_set_object_list
    if @export_set.new_record?
      @export_set.bookmarked_objects_for_export
    else
      @export_set.objects
    end
  end

  def csv_col_sep_options
    options_for_select(ExportSet::CSV_COL_SEP_OPTIONS.keys.collect { |opt| [opt.capitalize, opt] }, @export_set.csv_col_sep || "tab")
  end

  def object_list_cols
    if @export_set.export_content?
      [:pid, :object_type, :title, :identifier, :source]
    elsif @export_set.export_descriptive_metadata?
      [:pid, :object_type, :title, :description]
    end
  end

  def render_object_list_header(col)
    col == :pid ? "PID" : col.to_s.titleize
  end

  def render_object_list_row_value(obj, col)
    case col
    when :pid
      link_to(obj.id, url_for(obj))
    when :object_type
      obj.class.to_s
    when :title, :identifier, :description, :source
      obj.send(col).first
    else
      obj.send(col)
    end
  end

end
