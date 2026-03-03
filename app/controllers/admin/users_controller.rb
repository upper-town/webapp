module Admin
  class UsersController < BaseController
    def index
      @search_term = params[:q]
      @filter_start_date = params[:start_date]
      @filter_end_date = params[:end_date]
      @filter_start_time = params[:start_time]
      @filter_end_time = params[:end_time]
      @filter_time_zone = params[:time_zone].presence || cookies["browser_time_zone"]
      @filter_time_zone_param_present = params[:time_zone].present?
      @filter_date_column = params[:date_column].presence || "created_at"
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      relation = Admin::UsersQuery.call(
        search_term: @search_term,
        start_date: @filter_start_date,
        end_date: @filter_end_date,
        start_time: @filter_start_time,
        end_time: @filter_end_time,
        time_zone: @filter_time_zone,
        date_column: @filter_date_column,
        sort_key: @sort_key,
        sort_dir: @sort_dir
      )
      @pagination = Pagination.new(relation, request, per_page: 50)
      @users = @pagination.results

      render(status: :ok)
    end

    def show
      @user = user_from_params
    end

    def edit
      @user = user_from_params
      @form = Admin::Users::EditForm.new(user: @user)
    end

    def update
      @user = user_from_params
      @form = Admin::Users::EditForm.new(user: @user, **update_params)

      if @form.invalid?
        flash.now[:alert] = @form.errors
        render(:edit, status: :unprocessable_entity)
        return
      end

      result = Admin::Users::Update.call(@user, @form)

      if result.success?
        flash[:notice] = t("admin.users.update.success")
        redirect_to(admin_user_path(result.user))
      else
        @form.errors.merge!(result.errors)
        flash.now[:alert] = result.errors
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def user_from_params
      User.includes(account: :verified_servers).find(params[:id])
    end

    def update_params
      filtered = params.expect(admin_users_edit_form: [:locked, :locked_reason, :locked_comment])
      (filtered || {}).to_h.symbolize_keys
    end
  end
end
