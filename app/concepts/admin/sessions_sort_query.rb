module Admin
  class SessionsSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "sessions.id",
        "user_id" => "sessions.user_id",
        "created_at" => "sessions.created_at"
      }
    end
  end
end
