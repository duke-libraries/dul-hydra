module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def link_to_document(doc, opts = {:label => nil, :counter => nil})
    opts[:label] ||= blacklight_config.index.show_link.to_sym
    label = render_document_index_label doc, opts
    if can? :read, doc
      link_to label, object_path(doc.id)
    else
      content_tag :span, label
    end
  end

end
