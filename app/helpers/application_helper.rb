module ApplicationHelper
  include Pagy::Frontend

  def portal_date(value)
    return "-" if value.blank?

    I18n.l(value.to_date, format: "%Y.%m.%d")
  end

  def portal_datetime(value)
    return "-" if value.blank?

    I18n.l(value.in_time_zone, format: "%Y.%m.%d %H:%M")
  end

  def portal_month_day(value)
    return "-" if value.blank?

    I18n.l(value.to_date, format: "%m.%d")
  end
end
