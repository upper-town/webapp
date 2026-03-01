module Admin
  class AdminAccountsQuery
    include Callable

    def call
      AdminAccount.includes(:admin_user, :roles).order(id: :desc)
    end
  end
end
