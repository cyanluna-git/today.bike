module Portal
  class SessionsController < ApplicationController
    layout "portal"

    helper_method :current_customer

    def new
      redirect_to portal_root_path if session[:customer_id]
    end

    def create
      phone = params[:phone].to_s.strip
      customer = Customer.find_by(phone: phone)

      if customer
        session[:customer_id] = customer.id
        redirect_to portal_root_path, notice: "로그인되었습니다."
      else
        flash.now[:alert] = "등록된 전화번호가 없습니다."
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session.delete(:customer_id)
      redirect_to portal_login_path, notice: "로그아웃되었습니다."
    end

    # Stub for future Kakao OAuth callback
    def kakao_callback
      # When Kakao OAuth is configured, this will receive:
      #   - auth hash with uid, info (nickname, email, phone)
      #
      # For now, just redirect to the login page
      kakao_uid = params[:uid]
      if kakao_uid.present?
        customer = Customer.find_by(kakao_uid: kakao_uid)
        if customer
          session[:customer_id] = customer.id
          redirect_to portal_root_path, notice: "카카오 로그인 성공"
          return
        end
      end

      redirect_to portal_login_path, alert: "카카오 로그인은 준비 중입니다."
    end

    private

    def current_customer
      @current_customer ||= Customer.find_by(id: session[:customer_id]) if session[:customer_id]
    end
  end
end
