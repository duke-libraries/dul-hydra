class BatchFixityCheck
  class << self
    extend Deprecation

    def call(before_days: DulHydra.fixity_check_period_in_days,
             limit: DulHydra.fixity_check_limit)
      counter = 0
      not_checked(max: limit).each_id do |id|
        counter += 1
        enqueue(id)
      end

      if counter < limit
        max = limit - counter
        last_checked(before_days: before_days, max: max).each_id do |id|
          enqueue(id)
        end
      end
    end
    alias_method :check, :call
    deprecation_deprecate :check

    private

    # Return a query for objects not fixity checked
    def not_checked(max: nil)
      Ddr::Index::Query.build(max) do |max|
        absent :last_fixity_check_on
        limit max if max
      end
    end

    # Return a query for objects last checked more than `older_than_days` ago
    def last_checked(before_days: nil, max: nil)
      Ddr::Index::Query.build(before_days, max) do |days, max|
        asc :last_fixity_check_on
        if days
          before_days(:last_fixity_check_on, days)
        else
          present :last_fixity_check_on
        end
        limit max if max
      end
    end

    def enqueue(id)
      Resque.enqueue(FixityCheckJob, id)
    end
  end
end
