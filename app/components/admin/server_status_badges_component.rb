module Admin
  class ServerStatusBadgesComponent < ApplicationComponent
    attr_reader :server

    def initialize(server:)
      super()

      @server = server
    end

    def badges
      result = []
      if server.verified?
        result << content_tag(:span, t("admin.shared.verified"),
class: "badge text-bg-success")
      end
      if server.archived?
        result << content_tag(:span, t("admin.shared.archived"),
class: "badge text-bg-secondary")
      end
      if server.marked_for_deletion?
        result << content_tag(:span, t("admin.shared.marked_for_deletion"),
class: "badge text-bg-danger")
      end
      if result.empty?
        result << content_tag(:span, t("admin.shared.not_verified"),
class: "badge text-bg-light")
      end
      safe_join(result, " ")
    end
  end
end
