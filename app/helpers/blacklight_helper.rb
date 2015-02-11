module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def link_to_document(doc, field_or_opts = nil, opts={:counter => nil})
    field = field_or_opts || document_show_link_field(doc)
    label = presenter(doc).render_document_index_label field, opts
    if can? :read, doc
      link_to label, document_or_object_url(doc)
    else
      content_tag :span, label
    end
  end

end
