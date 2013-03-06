module DulHydra::Scripts
  module FixityCheck
    
    # TODO migrate defaults to config
    DEFAULT_LIMIT = 100
    DEFAULT_PERIOD = "6MONTHS"
    QUERY = "last_fixity_check_on_dt:[* TO NOW-%s] AND (active_fedora_model_s:Component OR active_fedora_model_s:Target)"
    SORT = "last_fixity_check_on_dt asc"

    def execute(limit=DEFAULT_LIMIT, period=DEFAULT_PERIOD, dryrun=false)
      # log info - Starting fixity check run ...
      if dryrun
        # log info 
      end
      query = QUERY % period
      # log info - querying index for objects: query (limit: limit)
      result = ActiveFedora::SolrService.query(query, :rows => limit, :sort => SORT)
      # log info - # objects found (result.size)
      result.each do |r|
        doc = SolrDocument.new(r)
        unless doc.datastreams.has_key? 'content'
          # log warning - no content
          next
        end
        begin
          # log info - retrieving object for fixity check
          obj = ActiveFedora::Base.find(doc.id, :cast => true) # need :cast => true ?
          if dryrun
            event = obj.validate_content_checksum
          else
            event = obj.validate_content_checksum!
          end
          # log_level = event.success? ? INFO : ERROR
          # log outcome
        rescue ActiveFedora::ObjectNotFoundError
          # log not found error
        end
      end
      # log info - Fixity check run complete.
    end

  end
end
