module Admin
  class AdminCodesFilterQuery < Filter::Base
    include Filter::ByValues

    private

    def scopes
      by_values(relation, params[:admin_user_id], column: :admin_user_id)
    end
  end
end
