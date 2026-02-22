# frozen_string_literal: true

module Admin
  module WebhookConfigs
    class Create
      include Callable

      class Result < ApplicationResult
        attribute :webhook_config
      end

      attr_reader :form

      def initialize(form)
        @form = form
      end

      def call
        webhook_config = WebhookConfig.new(form.webhook_config_attributes)

        if webhook_config.invalid?
          return Result.failure(webhook_config.errors)
        end

        webhook_config.save!
        Result.success(webhook_config:)
      end
    end
  end
end
