# frozen_string_literal: true

require "test_helper"

module Admin
  module Games
    class CreateTest < ActiveSupport::TestCase
      let(:described_class) { Create }

      describe "#call" do
        it "creates a game with valid attributes" do
          form = Admin::Games::Form.new(
            name: "Test Game",
            slug: "test-game",
            site_url: "https://minecraft.net",
            description: "A test game",
            info: "More info"
          )
          result = described_class.call(form)

          assert result.success?
          assert_equal "Test Game", result.game.name
          assert_equal "test-game", result.game.slug
          assert_equal "https://minecraft.net", result.game.site_url
          assert_equal "A test game", result.game.description
          assert_equal "More info", result.game.info
        end

        it "auto-generates slug from name when slug is blank" do
          form = Admin::Games::Form.new(name: "Perfect World International", site_url: "")
          result = described_class.call(form)

          assert result.success?
          assert_equal "Perfect World International", result.game.name
          assert_equal "perfect-world-international", result.game.slug
        end

        it "returns failure when name is invalid" do
          form = Admin::Games::Form.new(name: "ab", slug: "ab")
          result = described_class.call(form)

          assert result.failure?
          assert_includes result.errors[:name], "is too short (minimum is 3 characters)"
        end

        it "returns failure when slug is duplicate" do
          create_game(slug: "existing-game", name: "Existing Game")

          form = Admin::Games::Form.new(name: "New Game", slug: "existing-game")
          result = described_class.call(form)

          assert result.failure?
          assert result.errors[:slug].present?
        end
      end
    end
  end
end
