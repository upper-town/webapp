module Admin
  class AdminUsersController < BaseController
    def index
      @search_term = params[:q]
      relation = Admin::AdminUsersQuery.new.call
      @pagination = Pagination.new(
        Admin::Queries::AdminUsersQuery.call(AdminUser, relation, @search_term),
        request,
        per_page: 50
      )
      @admin_users = @pagination.results

      render(status: :ok)
    end

    def show
      @admin_user = admin_user_from_params
    end

    def new
    end

    def create
    end

    def edit
      @admin_user = admin_user_from_params
      @form = Admin::AdminUsers::EditForm.new(admin_user: @admin_user)
    end

    def update
      @admin_user = admin_user_from_params
      @form = Admin::AdminUsers::EditForm.new(admin_user: @admin_user, **update_params)

      if @form.invalid?
        flash.now[:alert] = @form.errors
        render(:edit, status: :unprocessable_entity)
        return
      end

      result = Admin::AdminUsers::Update.call(@admin_user, @form)

      if result.success?
        flash[:notice] = t("admin.admin_users.update.success")
        redirect_to(admin_admin_user_path(result.admin_user))
      else
        @form.errors.merge!(result.errors)
        flash.now[:alert] = result.errors
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def admin_user_from_params
      AdminUser.includes(account: :roles).find(params[:id])
    end

    def update_params
      filtered = params.expect(admin_admin_users_edit_form: [:locked, :locked_reason, :locked_comment])
      (filtered[:admin_admin_users_edit_form] || filtered["admin_admin_users_edit_form"] || {}).to_h.symbolize_keys
    end
  end
end
