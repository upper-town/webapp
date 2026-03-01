module Admin
  class WebhookConfigsController < BaseController
    def index
      @search_term = params[:q]
      relation = Admin::WebhookConfigsQuery.new.call
      @pagination = Pagination.new(
        Admin::Queries::WebhookConfigsQuery.call(WebhookConfig, relation, @search_term),
        request,
        per_page: 50
      )
      @webhook_configs = @pagination.results

      render(status: :ok)
    end

    def show
      @webhook_config = webhook_config_from_params
    end

    def new
      @form = Admin::WebhookConfigs::Form.new
      @servers = Server.includes(:game).order(:name)
    end

    def create
      @form = Admin::WebhookConfigs::Form.new(webhook_config_form_params)

      if @form.invalid?
        @servers = Server.includes(:game).order(:name)
        flash.now[:alert] = @form.errors
        render(:new, status: :unprocessable_entity)
        return
      end

      result = Admin::WebhookConfigs::Create.call(@form)

      if result.success?
        flash[:notice] = t("admin.webhook_configs.create.success")
        redirect_to(admin_webhook_config_path(result.webhook_config))
      else
        @form.errors.merge!(result.errors)
        @servers = Server.includes(:game).order(:name)
        flash.now[:alert] = result.errors
        render(:new, status: :unprocessable_entity)
      end
    end

    def edit
      @webhook_config = webhook_config_from_params
      @form = Admin::WebhookConfigs::Form.new(
        webhook_config: @webhook_config,
        **webhook_config_form_params_from_record(@webhook_config)
      )
      @servers = Server.includes(:game).order(:name)
    end

    def update
      @webhook_config = webhook_config_from_params
      @form = Admin::WebhookConfigs::Form.new(webhook_config: @webhook_config, **webhook_config_form_params)

      if @form.invalid?
        @servers = Server.includes(:game).order(:name)
        flash.now[:alert] = @form.errors
        render(:edit, status: :unprocessable_entity)
        return
      end

      result = Admin::WebhookConfigs::Update.call(@webhook_config, @form)

      if result.success?
        flash[:notice] = t("admin.webhook_configs.update.success")
        redirect_to(admin_webhook_config_path(result.webhook_config))
      else
        @form.errors.merge!(result.errors)
        @servers = Server.includes(:game).order(:name)
        flash.now[:alert] = result.errors
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def webhook_config_from_params
      WebhookConfig.includes(:source).find(params[:id])
    end

    def webhook_config_form_params
      filtered = params.expect(webhook_config: [
        :server_id,
        :url,
        :secret,
        :method,
        :event_types_string,
        :disabled
      ])
      raw = (filtered[:webhook_config] || filtered["webhook_config"] || {}).to_h.symbolize_keys
      {
        server_id: raw[:server_id].presence&.to_i,
        url: raw[:url],
        secret: raw[:secret],
        method: raw[:method],
        event_types_string: raw[:event_types_string],
        disabled: ActiveModel::Type::Boolean.new.cast(raw[:disabled])
      }
    end

    def webhook_config_form_params_from_record(webhook_config)
      {
        server_id: webhook_config.source_type == "Server" ? webhook_config.source_id : nil,
        url: webhook_config.url,
        method: webhook_config.method,
        event_types_string: webhook_config.event_types.join(", "),
        disabled: webhook_config.disabled?
      }
    end
  end
end
