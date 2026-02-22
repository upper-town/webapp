# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    def index
      @search_term = params[:q]
      relation = Admin::UsersQuery.new.call
      @pagination = Pagination.new(
        Admin::Queries::UsersQuery.call(User, relation, @search_term),
        request,
        per_page: 50
      )
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
      (filtered[:admin_users_edit_form] || filtered["admin_users_edit_form"] || {}).to_h.symbolize_keys
    end
  end
end
