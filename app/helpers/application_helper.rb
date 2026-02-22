# frozen_string_literal: true

module ApplicationHelper
  def default_title
    "upper.town"
  end

  def no_script
    "JavaScript is currently disabled on your browser. This website doesn't work without JavaScript."
  end

  def nav_link_class(*paths)
    base = "nav-link"
    return base unless paths.any? { |p| current_page_for_nav?(p) }
    "#{base} active"
  end

  def current_page_for_nav?(path)
    return false if path.blank?
    normalized = path.to_s.delete_suffix("/")
    return true if request.path == normalized || request.path == "#{normalized}/"
    # For root paths like /admin, avoid matching children (e.g. /admin/users)
    return false if normalized == "/admin"
    request.path.start_with?("#{normalized}/")
  end
end
