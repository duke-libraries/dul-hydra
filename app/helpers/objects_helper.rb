module ObjectsHelper

  def terms_for_creating
    if @object.respond_to?(:terms_for_creating)
      @object.terms_for_creating
    else
      DulHydra.terms_for_creating
    end
  end

  def form_field_name_for_creating(term)
    "object[#{term}]"
  end

  def form_field_value_for_creating(term)
    @object[term].first
  end

  def form_field_label_for_creating(term)
    label_tag form_field_name_for_creating(term), term.to_s.titleize
  end

  def form_field_for_creating(term)
    case term
    when :description
      text_area_tag form_field_name_for_creating(term), form_field_value_for_creating(term), cols: "50", rows: "5", class: "span5"
    when :admin_policy_id
      select_tag form_field_name_for_creating(term), options_for_select(AdminPolicy.all.collect {|apo| [apo.title, apo.pid]}), class: "span5"
    else
	  text_field_tag form_field_name_for_creating(term), form_field_value_for_creating(term), class: "span5"
    end
  end

end
