# frozen_string_literal: true

module Admin
  class AdminRolesQuery
    include Callable

    def call
      AdminRole.includes(:permissions).order(:key)
    end
  end
end
