class ReindexCollectionContents

  TRIGGER_ON_CHANGED = %w( admin_set title )

  def self.call(collection_or_id)
    validate! collection_or_id
    query = Ddr::Index::Query.build(collection_or_id) do |collection|
      is_governed_by collection
      negative :active_fedora_model, "Collection"
      field :id
    end
    ReindexQueryResult.call(query)
  end

  def self.trigger(event)
    payload = event.payload
    id, changes = payload.values_at(:pid, :changes)
    changed = changes.keys
    call(id) if (changed & TRIGGER_ON_CHANGED).present?
  end

  def self.validate!(collection_or_id)
    case collection_or_id
    when Collection
      if collection_or_id.new_record?
        raise ArgumentError,
              "Collection is not persisted: #{collection_or_id.inspect}."
      end
    when String
      unless Collection.exists?(collection_or_id)
        raise ActiveFedora::ObjectNotFoundError,
              "No Collection having PID #{collection_or_id} was found in the index."
      end
    else
      raise TypeError, "Argument must be a Collection instance or PID (string)."
    end
  end

end

ActiveSupport::Notifications.subscribe("save.collection") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  ReindexCollectionContents.trigger(event)
end
