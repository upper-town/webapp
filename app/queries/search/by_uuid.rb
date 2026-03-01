module Search
  module ByUuid
    UUID_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

    private

    def match_uuid?
      term.match?(UUID_PATTERN)
    end

    def by_uuid(table_column)
      if match_uuid?
        base_model.where("#{table_column} = ?", term)
      else
        base_model.none
      end
    end
  end
end
