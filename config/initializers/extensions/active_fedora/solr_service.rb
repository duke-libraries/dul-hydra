ActiveFedora::SolrService.class_eval do
  
  def self.post_query(query, args={})
    raw = args.delete(:raw)
    args = args.merge(:q=>query, :qt=>'standard')
    result = instance.conn.post('select', :data=>args)
    return result if raw
    result['response']['docs']
  end

end
