module Admin
  class GamesSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "games.id",
        "name" => "games.name",
        "slug" => "games.slug",
        "site_url" => "games.site_url"
      }
    end
  end
end
