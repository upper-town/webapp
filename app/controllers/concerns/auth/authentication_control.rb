module Auth
  module AuthenticationControl
    class NotAuthenticatedError < StandardError; end
    class ExpiredSessionError < StandardError; end
    class UnconfirmedEmailError < StandardError; end
    class LockedError < StandardError; end

    extend ActiveSupport::Concern

    include ManageSession
    include ManageReturnTo

    included do
      before_action(
        :current_session,
        :current_user,
        :current_account
      )
      helper_method(
        :current_session,
        :current_user,
        :current_account,
        :signed_in_user?,
        :signed_out_user?
      )

      rescue_from(NotAuthenticatedError, with: :handle_user_not_authenticated)
      rescue_from(ExpiredSessionError, with: :handle_user_expired_session)
      rescue_from(UnconfirmedEmailError, with: :handle_user_unconfirmed_email)
      rescue_from(LockedError, with: :handle_user_locked)
    end

    def ignored_return_to_paths
      [users_sign_out_path]
    end

    def authenticate_user!
      if !current_session
        raise NotAuthenticatedError
      end

      if current_session.expired?
        current_session.destroy!

        raise ExpiredSessionError
      end

      if current_user.unconfirmed_email? && request.path != users_sign_out_path
        raise UnconfirmedEmailError
      end

      if current_user.locked? && request.path != users_sign_out_path
        raise LockedError
      end
    end

    def handle_user_not_authenticated
      write_return_to

      redirect_to(
        users_sign_in_path,
        info: t("auth.authentication_control.not_authenticated")
      )
    end

    def handle_user_expired_session
      write_return_to

      redirect_to(
        users_sign_in_path,
        info: t("auth.authentication_control.expired_session")
      )
    end

    def handle_user_unconfirmed_email
      redirect_to(
        users_sign_up_path(email: current_user.email),
        info: t("auth.authentication_control.unconfirmed_email")
      )
    end

    def handle_user_locked
      redirect_to(
        root_path,
        info: t("auth.authentication_control.locked")
      )
    end
  end
end
