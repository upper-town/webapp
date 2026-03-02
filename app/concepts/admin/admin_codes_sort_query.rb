module Admin
  class AdminCodesSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "admin_codes.id",
        "admin_user_id" => "admin_codes.admin_user_id",
        "created_at" => "admin_codes.created_at"
      }
    end
  end
end
