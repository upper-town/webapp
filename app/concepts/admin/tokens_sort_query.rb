module Admin
  class TokensSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "tokens.id",
        "user_id" => "tokens.user_id",
        "created_at" => "tokens.created_at"
      }
    end
  end
end
