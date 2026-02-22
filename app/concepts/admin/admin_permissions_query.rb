# frozen_string_literal: true

module Admin
  class AdminPermissionsQuery
    include Callable

    def call
      AdminPermission.includes(:roles).order(:key)
    end
  end
end
