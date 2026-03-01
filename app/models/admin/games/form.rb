module Admin
  module Games
    class Form < ApplicationModel
      attribute :name, :string, default: nil
      attribute :slug, :string, default: nil
      attribute :site_url, :string, default: nil
      attribute :description, :string, default: nil
      attribute :info, :string, default: nil

      attr_accessor :game

      validates :name, presence: true, length: { minimum: 3, maximum: 255 }
      validates :slug, presence: true, if: :persisted?
      validates :site_url, allow_blank: true, length: { minimum: 3, maximum: 255 }, site_url: true
      validates :description, length: { maximum: 1_000 }, allow_blank: true
      validates :info, length: { maximum: 1_000 }, allow_blank: true

      def initialize(game: nil, **attrs)
        @game = game
        super(**attrs)
        populate_from_game if game.present?
      end

      def persisted?
        game&.persisted? == true
      end

      def self.model_name
        ActiveModel::Name.new(Game, nil, "Game")
      end

      def game_attributes
        { name:, slug:, site_url:, description:, info: }.compact
      end

      private

      def populate_from_game
        return if game.blank?

        self.name = game.name if name.nil?
        self.slug = game.slug if slug.nil?
        self.site_url = game.site_url if site_url.nil?
        self.description = game.description if description.nil?
        self.info = game.info if info.nil?
      end
    end
  end
end
