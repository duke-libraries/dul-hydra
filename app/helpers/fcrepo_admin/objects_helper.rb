module FcrepoAdmin::ObjectsHelper
  include FcrepoAdmin::Helpers::ObjectsHelperBehavior

  def object_title
    @object.title_display rescue "#{object_type} #{@object.pid}"
  end
end
