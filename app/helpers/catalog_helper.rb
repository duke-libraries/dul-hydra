module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def internal_uri_to_pid(args)
    args[:document][args[:field]].first.split('/').last
  end

end
