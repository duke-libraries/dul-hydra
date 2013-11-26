module ObjectsHelper

  def render_new_term_field(term)
    value = @model.multiple?(term) ? @object[term].first : @object[term]
    text_field_tag "#{params[:model]}[#{term}]", value, size: "50", class: "span5"
  end

end
