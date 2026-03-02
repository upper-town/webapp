module Admin
  class UsersFilterComponent < ApplicationComponent
    attr_reader :form, :start_date, :end_date, :start_time, :end_time, :time_zone,
                :time_zone_param_present, :date_column, :request

    FILTER_PARAMS = %w[start_date end_date start_time end_time time_zone date_column].freeze

    DATE_COLUMN_OPTIONS = [
      [:created_at, User.human_attribute_name(:created_at)],
      [:updated_at, User.human_attribute_name(:updated_at)],
      [:email_confirmed_at, User.human_attribute_name(:email_confirmed_at)],
      [:locked_at, User.human_attribute_name(:locked_at)]
    ].freeze

    def initialize(
      form:,
      start_date: nil,
      end_date: nil,
      start_time: nil,
      end_time: nil,
      time_zone: nil,
      time_zone_param_present: false,
      date_column: "created_at",
      request: nil
    )
      super()

      @form = form
      @start_date = start_date
      @end_date = end_date
      @start_time = start_time
      @end_time = end_time
      @time_zone = time_zone
      @time_zone_param_present = time_zone_param_present
      @date_column = date_column.presence || "created_at"
      @request = request
    end

    def date_column_options
      DATE_COLUMN_OPTIONS.map { |value, label| [label, value.to_s] }
    end

    def has_active_filters?
      start_date.present? || end_date.present? || start_time.present? || end_time.present? ||
        time_zone_param_present
    end
  end
end
