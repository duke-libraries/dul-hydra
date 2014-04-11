module RecordsHelper
  include RecordsHelperBehavior

  # override
  def record_form_action_url record
    url_for record
  end

  def field_name(key)
    "#{resource_instance_name}[#{key}][]"
  end

  def field_id(key)
    "#{resource_instance_name}_#{key}"
  end

  def more_or_less_button(key, html_class, symbol)
    content_tag('button', class: "#{html_class} btn btn-default", id: "additional_#{key}_submit", name: "additional_#{key}") do
      (symbol + 
      content_tag('span', class: 'accessible-hidden') do
        "add another #{key.to_s}"
      end).html_safe
    end
  end

end
