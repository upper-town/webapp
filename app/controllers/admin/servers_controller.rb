module Admin
  class ServersController < BaseController
    def index
      @search_term = params[:q]
      @filter_status_ids = params[:status]
      @filter_country_codes = params[:country_codes]
      @filter_game_ids = params[:game_ids]
      @sort_column = params[:sort].presence
      @sort_direction = params[:sort_dir].presence
      relation = Admin::ServersQuery.call(
        status: @filter_status_ids,
        country_codes: @filter_country_codes,
        game_ids: @filter_game_ids,
        sort: @sort_column,
        sort_dir: @sort_direction
      )
      @pagination = Pagination.new(
        Admin::Queries::ServersQuery.call(Server, relation, @search_term),
        request,
        per_page: 50
      )
      @servers = @pagination.results

      render(status: :ok)
    end

    def show
      @server = server_from_params
    end

    def edit
      @server = server_from_params
      @form = Admin::Servers::EditForm.new(server_edit_form_params_from_server(@server))
    end

    def update
      @server = server_from_params
      @form = Admin::Servers::EditForm.new(server_edit_form_params)

      if @form.invalid?
        flash.now[:alert] = @form.errors
        render(:edit, status: :unprocessable_entity)
        return
      end

      result = Admin::Servers::Update.call(@server, @form)

      if result.success?
        flash[:notice] = t("admin.servers.update.success")
        redirect_to(admin_server_path(result.server))
      else
        @form.errors.merge!(result.errors)
        flash.now[:alert] = result.errors
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def server_from_params
      Server.includes(:game, verified_accounts: :user).find(params[:id])
    end

    def server_edit_form_params
      filtered = params.expect(server: [
        :game_id,
        :country_code,
        :name,
        :site_url,
        :description,
        :info,
        :banner_image,
        :banner_image_approved
      ])
      raw = (filtered[:server] || filtered["server"] || {}).to_h.symbolize_keys
      {
        game_id: raw[:game_id],
        country_code: raw[:country_code],
        name: raw[:name],
        site_url: raw[:site_url],
        description: raw[:description],
        info: raw[:info],
        banner_image: raw[:banner_image],
        banner_image_approved: ActiveModel::Type::Boolean.new.cast(raw[:banner_image_approved])
      }.compact
    end

    def server_edit_form_params_from_server(server)
      {
        game_id: server.game_id,
        country_code: server.country_code,
        name: server.name,
        site_url: server.site_url,
        description: server.description,
        info: server.info,
        banner_image_approved: server.banner_image_approved?
      }.compact
    end
  end
end
