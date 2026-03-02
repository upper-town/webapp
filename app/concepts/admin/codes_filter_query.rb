module Admin
  class CodesFilterQuery < Filter::Base
    include Filter::ByValues

    private

    def scopes
      by_values(relation, params[:user_id], column: :user_id)
    end
  end
end
