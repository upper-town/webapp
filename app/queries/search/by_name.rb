module Search
  module ByName
    private

    def by_name(table_column)
      base_model.where("#{table_column} ILIKE ?", term_for_like)
    end
  end
end
