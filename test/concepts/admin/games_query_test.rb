# frozen_string_literal: true

require "test_helper"

class Admin::GamesQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::GamesQuery }

  describe "#call" do
    it "returns all games ordered by id desc" do
      game1 = create_game
      game2 = create_game
      game3 = create_game

      assert_equal(
        [
          game3,
          game2,
          game1
        ],
        described_class.new.call
      )
    end
  end
end
