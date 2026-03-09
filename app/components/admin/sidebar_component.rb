# frozen_string_literal: true

module Admin
  class SidebarComponent < ApplicationComponent
    def nav_link_class(*paths)
      helpers.nav_link_class(*paths)
    end

    def admin_jobs_access?
      helpers.admin_jobs_access?
    end
  end
end
