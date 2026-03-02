module Admin
  class AdminSessionsSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "admin_sessions.id",
        "admin_user_id" => "admin_sessions.admin_user_id",
        "created_at" => "admin_sessions.created_at"
      }
    end
  end
end
