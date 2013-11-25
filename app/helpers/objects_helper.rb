module ObjectsHelper

  def render_new_term_field(term)
    value = new_model.multiple?(term) ? new_object[term].first : new_object[term]
    text_field_tag "#{new_model.model_name.singular}[#{term}]", value, size: "50", class: "span5"
  end

end
