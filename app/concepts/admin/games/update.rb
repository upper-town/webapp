# frozen_string_literal: true

module Admin
  module Games
    class Update
      include Callable

      class Result < ApplicationResult
        attribute :game
      end

      attr_reader :game, :form

      def initialize(game, form)
        @game = game
        @form = form
      end

      def call
        game.assign_attributes(form.game_attributes)

        if game.invalid?
          return Result.failure(game.errors)
        end

        game.save!
        Result.success(game:)
      end
    end
  end
end
