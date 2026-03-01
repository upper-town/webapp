module Admin
  class GamesController < BaseController
    def index
      @search_term = params[:q]
      @sort_column = params[:sort].presence
      @sort_direction = params[:sort_dir].presence
      relation = Admin::GamesQuery.call(sort: @sort_column, sort_dir: @sort_direction)
      @pagination = Pagination.new(
        Admin::Queries::GamesQuery.call(Game, relation, @search_term),
        request,
        per_page: 50
      )
      @games = @pagination.results

      render(status: :ok)
    end

    def show
      @game = game_from_params
    end

    def new
      @form = Admin::Games::Form.new
    end

    def create
      @form = Admin::Games::Form.new(game_form_params)

      if @form.invalid?
        flash.now[:alert] = @form.errors
        render(:new, status: :unprocessable_entity)
        return
      end

      result = Admin::Games::Create.call(@form)

      if result.success?
        flash[:notice] = t("admin.games.create.success")
        redirect_to(admin_game_path(result.game))
      else
        @form.errors.merge!(result.errors)
        flash.now[:alert] = result.errors
        render(:new, status: :unprocessable_entity)
      end
    end

    def edit
      @game = game_from_params
      @form = Admin::Games::Form.new(game: @game)
    end

    def update
      @game = game_from_params
      @form = Admin::Games::Form.new(game: @game, **game_form_params)

      if @form.invalid?
        flash.now[:alert] = @form.errors
        render(:edit, status: :unprocessable_entity)
        return
      end

      result = Admin::Games::Update.call(@game, @form)

      if result.success?
        flash[:notice] = t("admin.games.update.success")
        redirect_to(admin_game_path(result.game))
      else
        @form.errors.merge!(result.errors)
        flash.now[:alert] = result.errors
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def game_from_params
      Game.find(params[:id])
    end

    def game_form_params
      filtered = params.expect(game: [:name, :slug, :site_url, :description, :info])
      (filtered[:game] || filtered["game"] || {}).to_h.symbolize_keys.compact
    end
  end
end
