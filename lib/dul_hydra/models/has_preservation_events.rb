module DulHydra::Models
  module HasPreservationEvents
    extend ActiveSupport::Concern

    included do
      has_many :preservation_events, 
               :property => :is_preservation_event_for, 
               :inbound => true, 
               :class_name => 'PreservationEvent'
      before_destroy :delete_preservation_events
    end

    def validate_checksum(dsID)
      PreservationEvent.validate_checksum(self, dsID)
    end

    def validate_checksum!(dsID)
      PreservationEvent.validate_checksum!(self, dsID)
    end

    # Used to record precise datastream version information.
    # Fedora's public API retrieves datastream versions by create date (asOfDateTime),
    # not by datastream version ID.
    def ds_internal_uri(dsID)
      "#{internal_uri}/datastreams/#{dsID}?asOfDateTime=#{DulHydra::Utils.ds_as_of_date_time(datastreams[dsID])}" 
    end

    def fixity_checks
      PreservationEvent.where(ActiveFedora::SolrService.solr_name(:is_preservation_event_for, :symbol) => internal_uri,
                              ActiveFedora::SolrService.solr_name(:event_type, :symbol) => PreservationEvent::FIXITY_CHECK
                              ).order("#{solr_sortable_date(:event_date_time)} asc")
    end

    def ingestions
      PreservationEvent.where(ActiveFedora::SolrService.solr_name(:is_preservation_event_for, :symbol) => internal_uri,
                              ActiveFedora::SolrService.solr_name(:event_type, :symbol) => PreservationEvent::INGESTION
                              ).order("#{solr_sortable_date(:event_date_time)} asc")
    end

    def validations
      PreservationEvent.where(ActiveFedora::SolrService.solr_name(:is_preservation_event_for, :symbol) => internal_uri,
                              ActiveFedora::SolrService.solr_name(:event_type, :symbol) => PreservationEvent::VALIDATION
                              ).order("#{solr_sortable_date(:event_date_time)} asc")
    end

    def last_fixity_check_to_solr
      e = fixity_checks.to_a.last
      e ? {
        solr_sortable_date(:last_fixity_check_on) => e.event_date_time,
        ActiveFedora::SolrService.solr_name(:last_fixity_check_outcome, :symbol) => e.event_outcome
      } : {}
    end

    module ClassMethods
      def find_by_last_fixity_check(before_date=Time.now.utc, limit=100)
        field = solr_sortable_date(:last_fixity_check_on)
        solr_date = before_date.respond_to?(:strftime) ? PreservationEvent.to_event_date_time(before_date) : before_date
        all({:sort => "#{field} asc",
              :rows => limit.to_s,
              :fq => "#{field}:[* TO #{solr_date}]"})
      end
    end

    protected

    def delete_preservation_events
      PreservationEvent.where(ActiveFedora::SolrService.solr_name(:is_preservation_event_for, :symbol) => internal_uri).delete_all
    end

    def solr_sortable_date(field)
      Solrizer.default_field_mapper.solr_name(field, :sortable, type: :date)
    end

  end
end
