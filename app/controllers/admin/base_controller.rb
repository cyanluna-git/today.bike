module Admin
  class BaseController < ApplicationController
    include Pagy::Backend

    before_action :authenticate_admin_user!
    layout "admin"
  end
end
