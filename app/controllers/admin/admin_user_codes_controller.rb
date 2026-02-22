# frozen_string_literal: true

module Admin
  class AdminUserCodesController < BaseController
    def index
      @admin_user = AdminUser.find(params[:id])
      @search_term = params[:q]
      relation = Admin::AdminCodesQuery.new(admin_user_id: @admin_user.id).call
      @pagination = Pagination.new(
        Admin::Queries::AdminCodesQuery.call(AdminCode, relation, @search_term),
        request,
        per_page: 50
      )
      @admin_codes = @pagination.results
    end
  end
end
