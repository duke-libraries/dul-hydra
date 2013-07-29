module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def link_to_document(doc, opts = {:label => nil, :counter => nil, :results_view => true})
    opts[:label] ||= blacklight_config.index.show_link.to_sym
    label = render_document_index_label doc, opts
    attrs = { :'data-counter' => opts[:counter] }.merge(opts.reject { |k,v| [:label, :counter, :results_view].include? k  })
    if can? :read, doc
      link_to label, doc, attrs
    else
      content_tag :span, label, attrs
    end
  end

end
