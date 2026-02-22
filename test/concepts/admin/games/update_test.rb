# frozen_string_literal: true

require "test_helper"

module Admin
  module Games
    class UpdateTest < ActiveSupport::TestCase
      let(:described_class) { Update }

      describe "#call" do
        it "updates a game with valid attributes" do
          game = create_game(name: "Old Name", slug: "old-slug")
          form = Admin::Games::Form.new(game:, name: "New Name", slug: "new-slug")

          result = described_class.call(game, form)

          assert result.success?
          assert_equal "New Name", result.game.name
          assert_equal "new-slug", result.game.slug
        end

        it "returns failure when name is invalid" do
          game = create_game
          form = Admin::Games::Form.new(game:, name: "ab")

          result = described_class.call(game, form)

          assert result.failure?
          assert_includes result.errors[:name], "is too short (minimum is 3 characters)"
        end
      end
    end
  end
end
