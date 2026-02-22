# frozen_string_literal: true

module Search
  module ByLastFour
    LAST_FOUR_PATTERN = /\A[a-z0-9]{4}\z/i

    private

    def match_last_four?
      term.match?(LAST_FOUR_PATTERN)
    end

    def by_last_four(table_column)
      if match_last_four?
        base_model.where("#{table_column} = ?", term)
      else
        base_model.none
      end
    end
  end
end
