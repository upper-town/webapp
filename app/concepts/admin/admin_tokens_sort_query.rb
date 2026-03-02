module Admin
  class AdminTokensSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "admin_tokens.id",
        "admin_user_id" => "admin_tokens.admin_user_id",
        "created_at" => "admin_tokens.created_at"
      }
    end
  end
end
