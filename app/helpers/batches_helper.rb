module BatchesHelper

  def batch_action(batch)
    case batch.status
    when Ddr::Batch::Batch::STATUS_READY
      # Temporarily remove the functionality requiring a separate validation step before processing
      # cf. issue #760
      #   link_to(I18n.t('batch.web.action_names.validate'), validate_batch_path(batch))
      link_to(I18n.t('batch.web.action_names.procezz'), procezz_batch_path(batch))
    when Ddr::Batch::Batch::STATUS_VALIDATED
      link_to(I18n.t('batch.web.action_names.procezz'), procezz_batch_path(batch))
    when Ddr::Batch::Batch::STATUS_RESTARTABLE
      link_to(I18n.t('batch.web.action_names.restart'), procezz_batch_path(batch))
    when Ddr::Batch::Batch::STATUS_INVALID
      link_to(I18n.t('batch.web.action_names.retry'), procezz_batch_path(batch))
    else
      "--"
    end
  end

  def batch_status_message(batch)
    case batch.status
    when nil
      "NEW"
    when Ddr::Batch::Batch::STATUS_PROCESSING
      "#{batch.status}&nbsp;#{batch.completed_count}/#{batch.batch_objects.count}<br /><em>#{est_time_to_complete(batch)}</em>".html_safe
    else
      batch.status
    end
  end

  def est_time_to_complete(batch)
    if batch.time_to_complete
      "#{distance_of_time_in_words(Time.now, Time.now + batch.time_to_complete)} remaining"
    end
  end

  def show_batch_tabs
      return @show_tabs if @show_tabs
      @show_tabs = []
      @show_tabs << {
        :label => I18n.t('batch.web.tab_names.batch_info'),
        :partial => 'show_batch_info',
        :id => 'tab-default',
        :active => true
      }
      @show_tabs << { :label => I18n.t('batch.web.tab_names.batch_objects'), :partial => 'show_batch_objects', :id => 'tab-batch-objects' }
      @show_tabs
  end

    def render_show_batch_tab(tab)
      opts = tab[:active] ? {class: "active"} : {}
      content_tag :li, opts do
        link_to tab[:label], "#" + tab[:id], "data-toggle" => "tab"
      end
    end

    def render_show_tab_batch_content(tab)
      css_class = tab[:active] ? "tab-pane active" : "tab-pane"
      content_tag :div, class: css_class, id: tab[:id] do
        render(tab[:partial])
      end
    end

    def render_validate_batch_link(batch)
      if batch.status.nil?
        link_to(I18n.t('batch.web.action_names.validate'), validate_batch_path(batch))
      end
    end

    def render_link_to_batch_with_name(batch)
      text = batch.id.to_s
      if batch.name.present? || batch.description.present?
        text << " ("
        text << batch.name if batch.name.present?
        text << " - " if batch.name.present? && batch.description.present?
        text << batch.description if batch.description.present?
        text << ")"
      end
      link_to(text, batch_path(batch))
    end

    def render_batch_delete_link(batch)
      case batch.status
      when nil, Ddr::Batch::Batch::STATUS_READY, Ddr::Batch::Batch::STATUS_VALIDATED, Ddr::Batch::Batch::STATUS_INVALID
        link_to content_tag(:span, "", :class => "glyphicon glyphicon-trash"), {:action => 'destroy', :id => batch}, :method => 'delete', :id => "batch_delete_#{batch.id}", :data => { :confirm => "#{t('batch.web.batch_deletion_confirmation', batch_id: batch.id)}" }
      end
    end
end
