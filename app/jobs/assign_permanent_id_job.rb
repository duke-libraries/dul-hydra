class AssignPermanentIdJob

  @queue = :permanent_id

  def self.perform(repo_id)
    Ddr::Models::PermanentId.assign!(repo_id)
  end

end
