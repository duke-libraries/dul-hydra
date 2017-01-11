class ReindexQueryResult

  def self.call(query)
    query.each_id { |id| reindex(id) }
  end

  def self.reindex(id)
    Resque.enqueue(UpdateIndexJob, id)
  end

end
