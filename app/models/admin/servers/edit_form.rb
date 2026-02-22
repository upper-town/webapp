# frozen_string_literal: true

module Admin
  module Servers
    class EditForm < ApplicationModel
      attribute :game_id, :integer, default: nil
      attribute :country_code, :string, default: nil
      attribute :name, :string, default: nil
      attribute :site_url, :string, default: nil
      attribute :description, :string, default: nil
      attribute :info, :string, default: nil
      attribute :banner_image
      attribute :banner_image_approved, :boolean, default: false

      validates :game_id, presence: true
      validate :validate_game_exists
      validates :country_code, inclusion: { in: Server::COUNTRY_CODES }, presence: true
      validates :name, presence: true, length: { minimum: 3, maximum: 255 }
      validates :site_url, presence: true, length: { minimum: 3, maximum: 255 }, site_url: true
      validates :description, length: { maximum: 1_000 }, allow_blank: true
      validates :info, length: { maximum: 1_000 }, allow_blank: true
      validate :validate_banner_image

      def self.model_name
        ActiveModel::Name.new(Server, nil, "Server")
      end

      def server_attributes
        {
          game_id:,
          country_code:,
          name:,
          site_url:,
          description:,
          info:
        }.compact
      end

      private

      def validate_game_exists
        return if game_id.blank?

        errors.add(:game_id, :invalid) unless Game.exists?(game_id)
      end

      def validate_banner_image
        return if banner_image.blank?

        banner_form = ServerBannerImage.new(uploaded_file: banner_image)
        banner_form.copy_errors_to(errors) if banner_form.invalid?
      end
    end
  end
end
