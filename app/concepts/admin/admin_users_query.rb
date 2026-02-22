# frozen_string_literal: true

module Admin
  class AdminUsersQuery
    include Callable

    def call
      AdminUser.order(id: :desc)
    end
  end
end
