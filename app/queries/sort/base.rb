module Sort
  class Base
    include Callable

    ID_COLUMN = "id"
    ASC  = "asc"
    DESC = "desc"

    attr_reader :relation, :sort_key, :sort_dir

    def initialize(relation, sort_key: nil, sort_dir: DESC)
      @relation = relation
      @sort_key = normalize_sort_key(sort_key)
      @sort_dir = normalize_sort_dir(sort_dir)
    end

    def call
      column = sort_key_columns[sort_key] || ID_COLUMN

      order = { column => sort_dir }
      order[ID_COLUMN] = DESC unless sorting_by_id?(column)

      relation.reorder(order)
    end

    private

    def sort_key_columns
      raise NotImplementedError
    end

    def normalize_sort_key(value)
      value.to_s.downcase
    end

    def normalize_sort_dir(value)
      value.to_s.downcase == ASC ? ASC : DESC
    end

    def sorting_by_id?(column)
      column.end_with?(".#{ID_COLUMN}") || column == ID_COLUMN
    end
  end
end
