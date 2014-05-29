class UniquenessValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    conditions = {attribute => value}
    conditions.merge!("-id" => record.id) if record.persisted?
    # Should be able to use record.class.exists?(conditions)
    # but ActiveFedora method only supports PIDs, not hash conditions
    # https://github.com/projecthydra/active_fedora/issues/427
    if record.class.where(conditions).first
      record.errors.add attribute, "has already been taken" 
    end
  end

end
