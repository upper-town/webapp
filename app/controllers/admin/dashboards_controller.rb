# frozen_string_literal: true

module Admin
  class DashboardsController < BaseController
    def show
      @stats = Admin::DashboardStats.call
    end
  end
end
