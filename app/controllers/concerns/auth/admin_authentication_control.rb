module Auth
  module AdminAuthenticationControl
    class NotAuthenticatedError < StandardError; end
    class ExpiredSessionError < StandardError; end
    class UnconfirmedEmailError < StandardError; end
    class LockedError < StandardError; end

    extend ActiveSupport::Concern

    include ManageAdminSession
    include ManageReturnTo

    included do
      before_action(
        :current_admin_session,
        :current_admin_user,
        :current_admin_account
      )
      helper_method(
        :current_admin_session,
        :current_admin_user,
        :current_admin_account,
        :signed_in_admin_user?,
        :signed_out_admin_user?,
        :admin_jobs_access?
      )

      rescue_from(NotAuthenticatedError, with: :handle_admin_user_not_authenticated)
      rescue_from(ExpiredSessionError, with: :handle_admin_user_expired_session)
      rescue_from(UnconfirmedEmailError, with: :handle_admin_user_unconfirmed_email)
      rescue_from(LockedError, with: :handle_admin_user_locked)
    end

    def ignored_return_to_paths
      [admin_users_sign_out_path]
    end

    def authenticate_admin_user!
      if !current_admin_session
        raise NotAuthenticatedError
      end

      if current_admin_session.expired?
        current_admin_session.destroy!

        raise ExpiredSessionError
      end

      if current_admin_user.unconfirmed_email? && request.path != admin_users_sign_out_path
        raise UnconfirmedEmailError
      end

      if current_admin_user.locked? && request.path != admin_users_sign_out_path
        raise LockedError
      end
    end

    def handle_admin_user_not_authenticated
      write_return_to

      redirect_to(
        admin_users_sign_in_path,
        info: t("auth.admin_authentication_control.not_authenticated")
      )
    end

    def handle_admin_user_expired_session
      write_return_to

      redirect_to(
        admin_users_sign_in_path,
        info: t("auth.admin_authentication_control.expired_session")
      )
    end

    def handle_admin_user_unconfirmed_email
      redirect_to(
        admin_users_sign_up_path(email: current_admin_user.email),
        info: t("auth.admin_authentication_control.unconfirmed_email")
      )
    end

    def handle_admin_user_locked
      redirect_to(
        admin_root_path,
        info: t("auth.admin_authentication_control.locked")
      )
    end

    def admin_jobs_access?
      Admin::AccessPolicy
        .new(current_admin_account, AdminPermission::JOBS_ACCESS)
        .allowed?
    end
  end
end
