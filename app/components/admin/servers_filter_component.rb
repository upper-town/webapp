module Admin
  class ServersFilterComponent < ApplicationComponent
    attr_reader :form, :selected_value_status, :selected_value_country_code

    FILTER_PARAMS = %w[status country_code].freeze

    def initialize(
      form:,
      selected_value_status: nil,
      selected_value_country_code: nil,
      request: nil
    )
      super()

      @form = form
      @selected_value_status = selected_value_status
      @selected_value_country_code = selected_value_country_code
      @request = request
      # clear_url ignored; FilterComponent builds it from request via RequestHelper
    end

    def has_active_filters?
      selected_value_status.present? || selected_value_country_code.present?
    end

    def status_options
      [
        [t("admin.servers.index.filter.all_statuses"), nil],
        [t("admin.servers.index.filter.verified"), "verified"],
        [t("admin.servers.index.filter.not_verified"), "not_verified"],
        [t("admin.servers.index.filter.archived"), "archived"],
        [t("admin.servers.index.filter.not_archived"), "not_archived"],
        [t("admin.servers.index.filter.marked_for_deletion"), "marked_for_deletion"]
      ]
    end

    def select_class
      "form-select form-select-sm admin-servers-filter-inline__select"
    end
  end
end
