# frozen_string_literal: true

module Admin
  module FeatureFlags
    class Create
      include Callable

      class Result < ApplicationResult
        attribute :feature_flag
      end

      attr_reader :form

      def initialize(form)
        @form = form
      end

      def call
        feature_flag = FeatureFlag.new(form.feature_flag_attributes)

        if feature_flag.invalid?
          return Result.failure(feature_flag.errors)
        end

        feature_flag.save!
        Result.success(feature_flag:)
      end
    end
  end
end
