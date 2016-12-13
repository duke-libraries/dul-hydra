class AssignPermanentIdJob

  @queue = :permanent_id

  def self.perform(repo_id)
    PermanentId.assign!(repo_id)
  end

end
