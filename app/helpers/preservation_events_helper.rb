module PreservationEventsHelper

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
