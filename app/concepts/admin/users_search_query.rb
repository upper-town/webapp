module Admin
  class UsersSearchQuery < Search::Base
    include Search::ById
    include Search::ByEmail

    private

    def scopes
      relation
        .merge(
          by_id("users.id")
            .or(by_email("users.email"))
        )
    end
  end
end
