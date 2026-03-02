module Admin
  class AdminPermissionsController < BaseController
    def index
      @search_term = params[:q]
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      relation = Admin::AdminPermissionsQuery.call(
        search_term: @search_term,
        sort_key: @sort_key,
        sort_dir: @sort_dir
      )
      @pagination = Pagination.new(relation, request, per_page: 50)
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
