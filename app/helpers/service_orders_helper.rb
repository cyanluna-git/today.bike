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

  def progress_review_badge_class(review_state)
    case review_state
    when "under_review"
      "bg-amber-100 text-amber-800"
    when "approval_needed"
      "bg-sky-100 text-sky-800"
    when "confirmed"
      "bg-emerald-100 text-emerald-800"
    else
      "bg-gray-100 text-gray-700"
    end
  end

  def progress_entry_badge_class(progress)
    if progress.manual_update?
      "bg-slate-100 text-slate-700"
    else
      "bg-indigo-100 text-indigo-700"
    end
  end
end
