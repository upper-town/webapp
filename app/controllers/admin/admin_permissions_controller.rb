# frozen_string_literal: true

module Admin
  class AdminPermissionsController < BaseController
    def index
      @search_term = params[:q]
      relation = Admin::AdminPermissionsQuery.new.call
      @pagination = Pagination.new(
        Admin::Queries::AdminPermissionsQuery.call(AdminPermission, relation, @search_term),
        request,
        per_page: 50
      )
      @admin_permissions = @pagination.results

      render(status: :ok)
    end

    def show
      @admin_permission = admin_permission_from_params
    end

    private

    def admin_permission_from_params
      AdminPermission.includes(:roles).find(params[:id])
    end
  end
end
