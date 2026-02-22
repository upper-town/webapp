# frozen_string_literal: true

module Admin
  class AdminTokensQuery
    include Callable

    def initialize(admin_user_id: nil)
      @admin_user_id = admin_user_id
    end

    def call
      scope = AdminToken.includes(:admin_user)
      scope = scope.where(admin_user_id: @admin_user_id) if @admin_user_id.present?
      scope.order(id: :desc)
    end
  end
end
