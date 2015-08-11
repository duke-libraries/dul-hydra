module Admin
  class BaseController < ::ApplicationController

    devise_group :admin, contains: [:superuser]
    before_action :authenticate_admin!

  end
end
