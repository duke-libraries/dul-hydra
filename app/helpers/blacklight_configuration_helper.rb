module BlacklightConfigurationHelper
  include Blacklight::ConfigurationHelperBehavior

  def default_sort_field
    if params.has_key? :q
      active_sort_fields.select { |k,config| config.default_for_user_query }.first.try(:last) || super
    else
      super
    end
  end

end
