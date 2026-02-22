# frozen_string_literal: true

module Search
  module ByEmail
    private

    def match_email?
      term.match?(ValidateEmail::PATTERN)
    end

    def by_email(table_column)
      if match_email?
        base_model.where("#{table_column} ILIKE ?", term_for_like)
      else
        base_model.none
      end
    end
  end
end
