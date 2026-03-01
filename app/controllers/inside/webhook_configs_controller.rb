module Inside
  class WebhookConfigsController < BaseController
    before_action :set_server

    def index
      @webhook_configs = @server.webhook_configs.order(id: :desc)
    end

    def show
      @webhook_config = webhook_config_from_params
    end

    def new
      @form = Admin::WebhookConfigs::Form.new(server_id: @server.id)
    end

    def create
      @form = Admin::WebhookConfigs::Form.new(**webhook_config_form_params, server_id: @server.id)

      if @form.invalid?
        flash.now[:alert] = @form.errors
        render(:new, status: :unprocessable_entity)
        return
      end

      result = Admin::WebhookConfigs::Create.call(@form)

      if result.success?
        redirect_to(
          inside_server_webhook_config_path(@server, result.webhook_config),
          success: t("inside.webhook_configs.create.success")
        )
      else
        @form.errors.merge!(result.errors)
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
    end

    def update
      @webhook_config = webhook_config_from_params
      @form = Admin::WebhookConfigs::Form.new(webhook_config: @webhook_config, **webhook_config_form_params)

      if @form.invalid?
        flash.now[:alert] = @form.errors
        render(:edit, status: :unprocessable_entity)
        return
      end

      result = Admin::WebhookConfigs::Update.call(@webhook_config, @form)

      if result.success?
        redirect_to(
          inside_server_webhook_config_path(@server, result.webhook_config),
          success: t("inside.webhook_configs.update.success")
        )
      else
        @form.errors.merge!(result.errors)
        flash.now[:alert] = result.errors
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def set_server
      @server = current_account.servers.find(params[:server_id])
    end

    def webhook_config_from_params
      @server.webhook_configs.find(params[:id])
    end

    def webhook_config_form_params
      filtered = params.expect(webhook_config: [
        :url,
        :secret,
        :method,
        :event_types_string,
        :disabled
      ])
      raw = filtered.to_h.symbolize_keys
      {
        url: raw[:url],
        secret: raw[:secret],
        method: raw[:method],
        event_types_string: raw[:event_types_string],
        disabled: ActiveModel::Type::Boolean.new.cast(raw[:disabled])
      }
    end

    def webhook_config_form_params_from_record(webhook_config)
      {
        url: webhook_config.url,
        method: webhook_config.method,
        event_types_string: webhook_config.event_types.join(", "),
        disabled: webhook_config.disabled?
      }
    end
  end
end
