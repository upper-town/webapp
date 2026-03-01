module Admin
  class GamesQuery
    include Callable

    def call
      Game.order(id: :desc)
    end
  end
end
