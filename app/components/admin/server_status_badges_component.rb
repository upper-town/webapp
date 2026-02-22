# frozen_string_literal: true

module Admin
  class ServerStatusBadgesComponent < ApplicationComponent
    attr_reader :server

    def initialize(server:)
      super()

      @server = server
    end

    def badges
      result = []
      result << content_tag(:span, t("admin.shared.verified"), class: "badge bg-success") if server.verified?
      result << content_tag(:span, t("admin.shared.archived"), class: "badge bg-secondary") if server.archived?
      result << content_tag(:span, t("admin.shared.marked_for_deletion"), class: "badge bg-danger") if server.marked_for_deletion?
      result << content_tag(:span, t("admin.shared.not_verified"), class: "badge bg-light text-dark") if result.empty?
      safe_join(result, " ")
    end
  end
end
