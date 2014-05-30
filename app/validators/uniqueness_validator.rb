class UniquenessValidator < ActiveModel::EachValidator

  def initialize(options = {})
    if options[:attributes].length > 1 
      raise ArgumentError, "UniquenessValidator accepts only a single attribute"
    end
    super
    @index_field = options[:index_field]
    # :index_type and :data_type options are ignored if :index_field is present
    @index_type = options[:index_type]
    @data_type = options[:data_type]
  end

  def validate_each(record, attribute, value)
    conditions = {index_field(attribute) => value}
    conditions.merge!("-id" => record.id) if record.persisted?
    # Should be able to use record.class.exists?(conditions)
    # but ActiveFedora method only supports PIDs, not hash conditions
    # https://github.com/projecthydra/active_fedora/issues/427
    if record.class.where(conditions).first
      record.errors.add attribute, "has already been taken" 
    end
  end

  private

  def index_field(attribute)
    return @index_field if @index_field
    args = [attribute]
    args << @index_type if @index_type
    args << {type: @data_type} if @data_type
    ActiveFedora::SolrService.solr_name(*args)
  end

end
