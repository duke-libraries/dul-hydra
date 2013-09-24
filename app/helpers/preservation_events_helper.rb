module PreservationEventsHelper

  def event_outcome_label(pe)
    content_tag :span, pe.event_outcome.capitalize, :class => "label label-#{pe.success? ? 'success' : 'important'}"
  end

  def event_outcome_detail_note_id(pe)
    # XXX This will work for pids, maybe not be other values
    "event-detail-#{pe.linking_object_id_value.sub(/:/, "_")}"
  end

  def event_outcome_detail_note_partial(pe)
    "#{pe.event_type.sub(/ /, "_")}_outcome_detail_note"
  end

  # def render_event_outcome_detail_note(pe)
  #   render partial: event_outcome_detail_note_partial(pe), locals: {detail: pe.event_outcome_detail_note}
  # end

end
