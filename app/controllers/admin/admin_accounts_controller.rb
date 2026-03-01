module Admin
  class AdminAccountsController < BaseController
    def index
      @search_term = params[:q]
      relation = Admin::AdminAccountsQuery.new.call
      @pagination = Pagination.new(
        Admin::Queries::AdminAccountsQuery.call(AdminAccount, relation, @search_term),
        request,
        per_page: 50
      )
      @admin_accounts = @pagination.results

      render(status: :ok)
    end

    def show
      @admin_account = admin_account_from_params
    end

    def edit
      @admin_account = admin_account_from_params
      @admin_roles = AdminRole.order(:key)
    end

    def update
      @admin_account = admin_account_from_params
      @admin_roles = AdminRole.order(:key)
      @form = Admin::AdminAccounts::UpdateRolesForm.new(update_roles_form_params)

      if @form.invalid?
        flash.now[:alert] = @form.errors
        render(:edit, status: :unprocessable_entity)
        return
      end

      result = Admin::AdminAccounts::UpdateRoles.call(@admin_account, @form)

      if result.success?
        flash[:notice] = t("admin.admin_accounts.update.success")
        redirect_to(admin_admin_account_path(result.admin_account))
      else
        flash.now[:alert] = result.errors
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def admin_account_from_params
      AdminAccount.includes(:admin_user, :roles, :permissions).find(params[:id])
    end

    def update_roles_form_params
      filtered = params.expect(admin_account: [:role_ids])
      (filtered[:admin_account] || filtered["admin_account"] || {}).to_h.symbolize_keys
    end
  end
end
