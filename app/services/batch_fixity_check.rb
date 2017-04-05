class BatchFixityCheck

  def self.call(before_days: nil, limit: nil)
    before_days ||= DulHydra.fixity_check_period_in_days
    limit       ||= DulHydra.fixity_check_limit
    counter = 0

    not_checked(limit: limit).each_id do |repo_id|
      counter += 1
      enqueue(repo_id)
    end

    if counter < limit
      last_checked(before_days: before_days, limit: limit-counter).each_id do |repo_id|
        enqueue(repo_id)
      end
    end
  end

  def self.not_checked(limit: nil)
    Ddr::Index::Query.build(limit) do |max|
      absent :last_fixity_check_on
      limit max if max
    end
  end

  def self.last_checked(before_days: nil, limit: nil)
    Ddr::Index::Query.build(before_days, limit) do |days, max|
      asc :last_fixity_check_on
      if days
        before_days(:last_fixity_check_on, days)
      else
        present :last_fixity_check_on
      end
    end
  end

  def self.enqueue(repo_id)
    Resque.enqueue(FixityCheckJob, repo_id)
  end

end
