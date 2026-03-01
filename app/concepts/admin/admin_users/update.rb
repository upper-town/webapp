module Admin
  module AdminUsers
    class Update
      include Callable

      class Result < ApplicationResult
        attribute :admin_user
      end

      attr_reader :admin_user, :form

      def initialize(admin_user, form)
        @admin_user = admin_user
        @form = form
      end

      def call
        return Result.failure(form.errors) if form.invalid?

        if form.locked?
          admin_user.lock_access!(form.locked_reason, form.locked_comment.presence)
        else
          admin_user.unlock_access!
        end

        Result.success(admin_user:)
      end
    end
  end
end
