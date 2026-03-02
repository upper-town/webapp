module Admin
  class AdminAccountsSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "admin_accounts.id",
        "created_at" => "admin_accounts.created_at"
      }
    end
  end
end
