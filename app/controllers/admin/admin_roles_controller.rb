module Admin
  class AdminRolesController < BaseController
    def index
      @search_term = params[:q]
      relation = Admin::AdminRolesQuery.new.call
      @pagination = Pagination.new(
        Admin::Queries::AdminRolesQuery.call(AdminRole, relation, @search_term),
        request,
        per_page: 50
      )
      @admin_roles = @pagination.results

      render(status: :ok)
    end

    def show
      @admin_role = admin_role_from_params
    end

    def edit
      @admin_role = admin_role_from_params
      @admin_permissions = AdminPermission.order(:key)
    end

    def update
      @admin_role = admin_role_from_params
      @admin_permissions = AdminPermission.order(:key)
      @form = Admin::AdminRoles::UpdateForm.new(update_form_params)

      if @form.invalid?
        flash.now[:alert] = @form.errors
        render(:edit, status: :unprocessable_entity)
        return
      end

      result = Admin::AdminRoles::Update.call(@admin_role, @form)

      if result.success?
        flash[:notice] = t("admin.admin_roles.update.success")
        redirect_to(admin_admin_role_path(result.admin_role))
      else
        flash.now[:alert] = result.errors
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def admin_role_from_params
      AdminRole.includes(:permissions, :accounts).find(params[:id])
    end

    def update_form_params
      filtered = params.expect(admin_role: [:permission_ids])
      (filtered[:admin_role] || filtered["admin_role"] || {}).to_h.symbolize_keys
    end
  end
end
