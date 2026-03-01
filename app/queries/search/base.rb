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
  end
end
