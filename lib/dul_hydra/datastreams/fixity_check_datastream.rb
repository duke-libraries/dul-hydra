module DulHydra::Datastreams

  class FixityCheckDatastream < ActiveFedora::NokogiriDatastream
    
    set_terminology do |t|
      t.root(:path => "fixityCheck")
      t.date_time(:path => "dateTime")
      t.outcome
      t.outcome_detail(:path => "outcomeDetail") 
    end
    
    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.fixityCheck {
          xml.dateTime
          xml.outcome
          xml.outcomeDetail 
        }
      end
      return builder.doc
    end

    def to_solr(solr_doc)
      solr_doc.merge!(ActiveFedora::SolrService.solr_name(:fixity_check_date, :date) => date_time,
                      ActiveFedora::SolrService.solr_name(:fixity_check_outcome, :symbol) => outcome)
      solr_doc
    end

  end

end
