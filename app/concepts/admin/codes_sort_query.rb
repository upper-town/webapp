module Admin
  class CodesSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "codes.id",
        "user_id" => "codes.user_id",
        "created_at" => "codes.created_at"
      }
    end
  end
end
