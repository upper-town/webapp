module Admin
  class UsersSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "users.id",
        "email" => "users.email",
        "email_confirmed_at" => "users.email_confirmed_at",
        "locked_at" => "users.locked_at"
      }
    end
  end
end
