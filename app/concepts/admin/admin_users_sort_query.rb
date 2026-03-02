module Admin
  class AdminUsersSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "admin_users.id",
        "email" => "admin_users.email",
        "email_confirmed_at" => "admin_users.email_confirmed_at",
        "locked_at" => "admin_users.locked_at"
      }
    end
  end
end
