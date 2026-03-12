class PagesController < ApplicationController
  def home
    @recent_posts = BlogPost.published.recent.limit(3)
  end

  VALID_SERVICE_TYPES = %w[overhaul repair fitting upgrade].freeze

  def service
    unless VALID_SERVICE_TYPES.include?(params[:service_type])
      raise ActionController::RoutingError, "Not Found"
    end

    @service_type = params[:service_type]
    @showcase_orders = ServiceOrder
      .where(service_type: service_type_mapping(@service_type))
      .where(showcase: true)
      .joins(:service_photos)
      .distinct
      .includes(:bicycle, :service_photos)
      .order(completed_at: :desc)
      .limit(6)
  end

  private

  def service_type_mapping(type)
    case type
    when "overhaul" then "overhaul"
    when "repair" then "repair"
    when "fitting" then "fitting"
    when "upgrade" then "upgrade"
    end
  end
end
