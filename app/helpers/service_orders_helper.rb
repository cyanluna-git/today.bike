module ServiceOrdersHelper
  def progress_dot_color(status)
    case status
    when "received"
      "bg-gray-500"
    when "diagnosis"
      "bg-yellow-500"
    when "in_progress"
      "bg-blue-500"
    when "completed"
      "bg-green-500"
    when "delivered"
      "bg-purple-500"
    else
      "bg-gray-400"
    end
  end

  def progress_badge_class(status)
    case status
    when "received"
      "bg-gray-100 text-gray-800"
    when "diagnosis"
      "bg-yellow-100 text-yellow-800"
    when "in_progress"
      "bg-blue-100 text-blue-800"
    when "completed"
      "bg-green-100 text-green-800"
    when "delivered"
      "bg-purple-100 text-purple-800"
    else
      "bg-gray-100 text-gray-700"
    end
  end
end
