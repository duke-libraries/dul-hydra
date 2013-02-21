module DulHydra::Models
  module Auditable
    
    def audit_trail
      @audit_trail ||= FedoraAuditTrail.new(self)
    end
    
    private
    
    AUDIT_TRAIL_NS = {'audit' => 'info:fedora/fedora-system:def/audit#'}
    
    class FedoraAuditTrail
      def initialize(object)
        @ng_xml = Nokogiri::XML(object.inner_object.repository.object_xml(:pid => object.pid)).xpath('/foxml:digitalObject/foxml:datastream[@ID = "AUDIT"]')  
      end
      def records
        if !@records
          @records = []
          @ng_xml.xpath('.//audit:record', AUDIT_TRAIL_NS).each do |node| 
            @records << FedoraAuditRecord.new(node)
          end
        end
        @records
      end
      def to_xml
        @ng_xml.to_xml
      end
    end
  
    class FedoraAuditRecord
      def initialize(node)
        @record = node
      end
      def id
        @record['ID']
      end
      def process
        @record.at_xpath('audit:process/@type', AUDIT_TRAIL_NS).text
      end
      def action
        @record.at_xpath('audit:action', AUDIT_TRAIL_NS).text
      end
      def component_id
        @record.at_xpath('audit:componentID', AUDIT_TRAIL_NS).text
      end
      def responsibility
        @record.at_xpath('audit:responsibility', AUDIT_TRAIL_NS).text
      end
      def date
        @record.at_xpath('audit:date', AUDIT_TRAIL_NS).text
      end
      def justification
        @record.at_xpath('audit:justification', AUDIT_TRAIL_NS).text
      end
    end    
        
  end
end