# frozen_string_literal: true

module Admin
  module FeatureFlags
    class Form < ApplicationModel
      attribute :name, :string, default: nil
      attribute :value, :string, default: nil
      attribute :comment, :string, default: nil

      attr_accessor :feature_flag

      validates :name, presence: true
      validates :value, presence: true

      def initialize(feature_flag: nil, **attrs)
        @feature_flag = feature_flag
        super(**attrs)
        populate_from_feature_flag if feature_flag.present?
      end

      def persisted?
        feature_flag&.persisted? == true
      end

      def self.model_name
        ActiveModel::Name.new(FeatureFlag, nil, "FeatureFlag")
      end

      def feature_flag_attributes
        { name:, value:, comment: }.compact
      end

      private

      def populate_from_feature_flag
        return if feature_flag.blank?

        self.name = feature_flag.name if name.nil?
        self.value = feature_flag.value if value.nil?
        self.comment = feature_flag.comment if comment.nil?
      end
    end
  end
end
