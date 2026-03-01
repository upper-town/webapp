module Search
  class Base
    include Callable

    attr_reader :base_model, :relation, :term

    def initialize(base_model, relation, term = nil)
      @base_model = base_model
      @relation = relation
      @term = term&.squish
    end

    def call
      return relation if term.blank?

      relation.scoping { scopes }
    end

    private

    def scopes
      raise NotImplementedError
    end

    def term_for_like(left: "%", right: "%")
      "#{left}#{ActiveRecord::Base.sanitize_sql_like(term)}#{right}"
    end

    # Validates and quotes table.column identifiers to satisfy Brakeman and prevent SQL injection.
    # Only allows identifiers matching /\A[a-z_][a-z0-9_]*\.[a-z_][a-z0-9_]*\z/i
    def sanitized_table_column(table_column)
      unless table_column.to_s.match?(/\A[a-z_][a-z0-9_]*\.[a-z_][a-z0-9_]*\z/i)
        raise ArgumentError, "Invalid table.column format: #{table_column.inspect}"
      end

      table, column = table_column.split(".", 2)
      conn = base_model.connection
      "#{conn.quote_table_name(table)}.#{conn.quote_column_name(column)}"
    end
  end
end
