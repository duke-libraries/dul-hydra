module BatchesHelper

  def batch_action(batch)
    case batch.status
    when nil
      link_to(I18n.t('batch.web.action_names.validate'), validate_batch_path(batch))
    when DulHydra::Batch::Models::Batch::STATUS_VALIDATED
      link_to(I18n.t('batch.web.action_names.procezz'), procezz_batch_path(batch))
    when DulHydra::Batch::Models::Batch::STATUS_RESTARTABLE
      link_to(I18n.t('batch.web.action_names.restart'), procezz_batch_path(batch))
    else
      batch.status
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
  
end
