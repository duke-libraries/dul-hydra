module DulHydra
  module ModelMixins

    module DescMetadata      
      def self.included(klass)
        klass.has_metadata :name => "descMetadata", :type => ModsContent
        klass.delegate_to 'descMetadata', [:identifier]
        klass.delegate :title, :to => 'descMetadata', :at => [:title_info, :main_title]
      end
    end

  end
end
