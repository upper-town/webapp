# frozen_string_literal: true

module Admin
  module Games
    class Create
      include Callable

      class Result < ApplicationResult
        attribute :game
      end

      attr_reader :form

      def initialize(form)
        @form = form
      end

      def call
        game = Game.new(form.game_attributes)
        game.slug = game.slug.presence || game.name&.parameterize

        if game.invalid?
          return Result.failure(game.errors)
        end

        game.save!
        Result.success(game:)
      end
    end
  end
end
