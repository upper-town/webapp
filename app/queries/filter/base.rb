module Filter
  class Base
    include Callable

    attr_reader :relation, :params

    def initialize(relation, params = {})
      @relation = relation
      @params = params.with_indifferent_access
    end

    def call
      return relation if params.blank?

      relation.scoping { scopes }
    end

    private

    def scopes
      raise NotImplementedError
    end
  end
end
