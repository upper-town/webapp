# frozen_string_literal: true

module Admin
  class AdminCodesController < BaseController
    def index
      @search_term = params[:q]
      relation = Admin::AdminCodesQuery.new.call
      @pagination = Pagination.new(
        Admin::Queries::AdminCodesQuery.call(AdminCode, relation, @search_term),
        request,
        per_page: 50
      )
      @admin_codes = @pagination.results

      render(status: :ok)
    end

    def show
      @admin_code = admin_code_from_params
    end

    private

    def admin_code_from_params
      AdminCode.includes(:admin_user).find(params[:id])
    end
  end
end
