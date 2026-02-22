# frozen_string_literal: true

module Admin
  class SessionsQuery
    include Callable

    def initialize(user_id: nil)
      @user_id = user_id
    end

    def call
      scope = Session.includes(:user)
      scope = scope.where(user_id: @user_id) if @user_id.present?
      scope.order(id: :desc)
    end
  end
end
