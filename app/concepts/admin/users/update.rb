module Admin
  module Users
    class Update
      include Callable

      class Result < ApplicationResult
        attribute :user
      end

      attr_reader :user, :form

      def initialize(user, form)
        @user = user
        @form = form
      end

      def call
        return Result.failure(form.errors) if form.invalid?

        if form.locked?
          user.lock_access!(form.locked_reason, form.locked_comment.presence)
        else
          user.unlock_access!
        end

        Result.success(user:)
      end
    end
  end
end
