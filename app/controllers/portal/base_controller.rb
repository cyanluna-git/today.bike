module Portal
  class BaseController < ApplicationController
    layout "portal"

    before_action :authenticate_customer!

    private

    def authenticate_customer!
      unless current_customer
        redirect_to portal_login_path, alert: "로그인이 필요합니다."
      end
    end

    def current_customer
      @current_customer ||= Customer.find_by(id: session[:customer_id]) if session[:customer_id]
    end
    helper_method :current_customer
  end
end
