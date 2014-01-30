class HasContentValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.has_content?
      record.errors[attribute] << "The \"#{value.dsid}\" datastream does not have content"
    end
  end
end
