require 'rsolr'

module ActiveFedora
  class SolrService
    extend Deprecation

    class << self
      def post_query(query, args={})
        raw = args.delete(:raw)
        args = args.merge(:q=>query, :qt=>'standard')
        result = SolrService.instance.conn.post('select', :data=>args)
        return result if raw
        result['response']['docs']
      end
    end

  end
end