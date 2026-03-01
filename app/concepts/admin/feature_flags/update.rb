module Admin
  module FeatureFlags
    class Update
      include Callable

      class Result < ApplicationResult
        attribute :feature_flag
      end

      attr_reader :feature_flag, :form

      def initialize(feature_flag, form)
        @feature_flag = feature_flag
        @form = form
      end

      def call
        feature_flag.assign_attributes(form.feature_flag_attributes)

        if feature_flag.invalid?
          return Result.failure(feature_flag.errors)
        end

        feature_flag.save!
        Result.success(feature_flag:)
      end
    end
  end
end
