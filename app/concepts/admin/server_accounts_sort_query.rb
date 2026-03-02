module Admin
  class ServerAccountsSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "server_accounts.id",
        "server" => "servers.name",
        "account" => "users.email",
        "created_at" => "server_accounts.created_at"
      }
    end
  end
end
