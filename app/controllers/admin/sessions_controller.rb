# frozen_string_literal: true

module Admin
  class SessionsController < BaseController
    def index
      @search_term = params[:q]
      relation = Admin::SessionsQuery.new.call
      @pagination = Pagination.new(
        Admin::Queries::SessionsQuery.call(Session, relation, @search_term),
        request,
        per_page: 50
      )
      @sessions = @pagination.results

      render(status: :ok)
    end

    def show
      @session = session_from_params
    end

    private

    def session_from_params
      Session.includes(:user).find(params[:id])
    end
  end
end
