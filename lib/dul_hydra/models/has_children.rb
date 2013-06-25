module DulHydra::Models
  module HasChildren
    extend ActiveSupport::Concern

    def first_child
      if datastreams.include?(DulHydra::Datastreams::CONTENT_METADATA) && datastreams[DulHydra::Datastreams::CONTENT_METADATA].has_content?
        first_child_pid = datastreams[DulHydra::Datastreams::CONTENT_METADATA].first_pid
        begin
          ActiveFedora::Base.find(first_child_pid, :cast => true) if first_child_pid
        rescue ActiveFedora::ObjectNotFound
          nil
        end
      else
        children.first
      end      
    end
    
  end
end