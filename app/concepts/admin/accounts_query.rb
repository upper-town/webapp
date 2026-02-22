# frozen_string_literal: true

module Admin
  class AccountsQuery
    include Callable

    def call
      Account.includes(:user, :verified_servers).order(id: :desc)
    end
  end
end
