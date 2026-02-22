# frozen_string_literal: true

module Admin
  module WebhookConfigs
    class Update
      include Callable

      class Result < ApplicationResult
        attribute :webhook_config
      end

      attr_reader :webhook_config, :form

      def initialize(webhook_config, form)
        @webhook_config = webhook_config
        @form = form
      end

      def call
        webhook_config.assign_attributes(form.webhook_config_attributes)

        if webhook_config.invalid?
          return Result.failure(webhook_config.errors)
        end

        webhook_config.save!
        Result.success(webhook_config:)
      end
    end
  end
end
