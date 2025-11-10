module ApplicationHelper
  def flash_class(type)
    case type.to_sym
    when :notice, :success
      "bg-green-100 text-green-800 border border-green-300"
    when :alert, :error
      "bg-red-100 text-red-800 border border-red-300"
    when :warning
      "bg-yellow-100 text-yellow-800 border border-yellow-300"
    else
      "bg-blue-100 text-blue-800 border border-blue-300"
    end
  end

  def flash_icon(type)
    case type.to_sym
    when :notice, :success
      "fa-solid fa-circle-check text-green-600"
    when :alert, :error
      "fa-solid fa-circle-exclamation text-red-600"
    when :warning
      "fa-solid fa-triangle-exclamation text-yellow-600"
    else
      "fa-solid fa-circle-info text-blue-600"
    end
  end
end
