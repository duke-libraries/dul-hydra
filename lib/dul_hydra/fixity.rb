module DulHydra
  class Fixity

    def self.check(before_days: DulHydra.fixity_check_period_in_days,
                   limit: DulHydra.fixity_check_limit)
      counter = 0
      not_checked(limit: limit).each_pid do |pid|
        counter += 1
        enqueue(pid)
      end

      if counter < limit
        last_checked(before_days: before_days, limit: limit-counter).each_pid do |pid|
          enqueue(pid)
        end
      end
    end

    # Return a query for objects not fixity checked
    def self.not_checked(limit: nil)
      builder = Ddr::Index::QueryBuilder.new
      builder.absent(Ddr::Index::Fields::LAST_FIXITY_CHECK_ON)
      if limit
        builder.limit(limit)
      end
      query = builder.query
      Rails.logger.debug "Fixity check query for objects not checked: #{query.inspect}"
      query
    end

    # Return a query for objects last checked more than `older_than_days` ago
    def self.last_checked(before_days: nil, limit: nil)
      builder = Ddr::Index::QueryBuilder.new
      builder.asc(Ddr::Index::Fields::LAST_FIXITY_CHECK_ON)
      if before_days
        builder.before_days(Ddr::Index::Fields::LAST_FIXITY_CHECK_ON, before_days)
      else
        builder.present(Ddr::Index::Fields::LAST_FIXITY_CHECK_ON)
      end
      if limit
        builder.limit(limit)
      end
      query = builder.query
      Rails.logger.debug "Fixity check query for objects last checked before days (#{before_days}): #{query.inspect}"
      query
    end

    def self.enqueue(pid)
      Resque.enqueue(Ddr::Jobs::FixityCheck, pid)
    end

  end
end
