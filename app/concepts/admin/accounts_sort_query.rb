module Admin
  class AccountsSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "accounts.id",
        "uuid" => "accounts.uuid",
        "created_at" => "accounts.created_at"
      }
    end
  end
end
