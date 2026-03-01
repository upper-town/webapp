module Search
  module ById
    ID_PATTERN = /\A[0-9]+\z/

    private

    def match_id?
      term.match?(ID_PATTERN)
    end

    def by_id(table_column)
      if match_id?
        base_model.where("#{table_column} = ?", term)
      else
        base_model.none
      end
    end
  end
end
