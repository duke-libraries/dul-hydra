module DulHydra::Jobs
  class MoveFirstIdentifierToLocalId

    @queue = :migration

    SUMMARY = "First identifier moved to local id"

    def self.perform(pid)
      event_args = { pid: pid, summary: SUMMARY }
      obj = ActiveFedora::Base.find(pid)
      details = [ "Before: local_id: #{obj.local_id} ; identifiers: #{obj.identifier}" ]
      moved = obj.move_first_identifier_to_local_id
      if moved
        obj.datastreams['descMetadata'].delete if obj.descMetadata.content == ''
        obj.save!
        obj.reload
        details << "After: local_id: #{obj.local_id} ; identifiers: #{obj.identifier}"
        event_args[:detail] = details.join("\n\n")
        Ddr::Events::UpdateEvent.create(event_args)
      end
    end

  end
end