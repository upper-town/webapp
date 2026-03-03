module Filter
  module ByValues
    private

    def by_values(scope, values, column:)
      values = normalize_values(values)
      return scope if values.blank?

      scope.where(column => values)
    end

    def normalize_values(values)
      Array(values).flatten.map { it.to_s.squish }.compact_blank
    end
  end
end
