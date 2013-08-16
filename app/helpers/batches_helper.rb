module BatchesHelper

  def batch_action(batch)
    if batch.batch_runs.empty?
      link_to(I18n.t('batch.web.action_names.procezz'), procezz_batch_path(batch))
    elsif batch.batch_runs.last.status == DulHydra::Batch::Models::BatchRun::STATUS_FINISHED
      link_to(I18n.t('batch.web.action_names.reprocezz'), procezz_batch_path(batch))
    else
      DulHydra::Batch::Models::BatchRun::STATUS_RUNNING
    end
  end

  def event_outcome_label(document)
    content_tag :span, document.event_outcome.capitalize, :class => "label label-#{document.event_outcome == PreservationEvent::SUCCESS ? 'success' : 'important'}"
  end

  def event_detail_id(document)
    "event-detail-#{document.safe_id}"
  end

  def event_detail_partial(document)
    "#{document.event_type.sub(/ /, "_")}_detail"
  end

  def render_event_detail(document)
    render partial: event_detail_partial(document), locals: {detail: document.parsed_event_outcome_detail_note}
  end

end
