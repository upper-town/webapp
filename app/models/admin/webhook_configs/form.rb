# frozen_string_literal: true

module Admin
  module WebhookConfigs
    class Form < ApplicationModel
      attribute :server_id, :integer, default: nil
      attribute :url, :string, default: nil
      attribute :secret, :string, default: nil
      attribute :method, :string, default: nil
      attribute :event_types_string, :string, default: nil
      attribute :disabled, :boolean, default: false

      validates :url, presence: true
      validates :method, inclusion: { in: WebhookConfig::METHODS }, presence: true
      validates :server_id, presence: true, if: -> { !persisted? }
      validates :secret, presence: true, if: -> { !persisted? }

      attr_accessor :webhook_config

      def initialize(webhook_config: nil, **attrs)
        @webhook_config = webhook_config
        super(**attrs)
        populate_from_webhook_config if webhook_config.present?
      end

      def persisted?
        webhook_config&.persisted? == true
      end

      def self.model_name
        ActiveModel::Name.new(WebhookConfig, nil, "WebhookConfig")
      end

      def webhook_config_attributes
        attrs = {}
        if server_id.present?
          attrs[:source_type] = "Server"
          attrs[:source_id] = server_id
        end
        attrs[:url] = url
        attrs[:method] = method
        attrs[:disabled_at] = disabled ? Time.current : nil
        attrs[:secret] = secret.presence if secret.present?
        attrs[:event_types] = parse_event_types(event_types_string) if event_types_string.present?
        attrs.compact
      end

      private

      def populate_from_webhook_config
        return if webhook_config.blank?

        self.url = webhook_config.url if url.nil?
        self.method = webhook_config.method if method.nil?
        self.event_types_string = webhook_config.event_types.join(", ") if event_types_string.nil?
        self.disabled = webhook_config.disabled? if disabled == false && !webhook_config.enabled?
        self.server_id = webhook_config.source_id if webhook_config.source_type == "Server" && server_id.nil?
      end

      def parse_event_types(string)
        string.to_s.split(/[,\n]/).map(&:strip).compact_blank.presence || ["*"]
      end
    end
  end
end
