class ReindexQueryResult

  def self.call(query)
    query.each_id { |id| reindex(id) }
  end

  def self.reindex(id)
    Resque.enqueue(Ddr::Jobs::UpdateIndex, id)
  end

end
