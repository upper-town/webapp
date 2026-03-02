module Admin
  class ServersSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "servers.id",
        "name" => "servers.name",
        "game" => "games.name",
        "site_url" => "servers.site_url",
        "country" => "servers.country_code",
        "status" => "servers.verified_at"
      }
    end
  end
end
