module Admin
  class FilterComponent < ApplicationComponent
    attr_reader :form, :clear_url, :has_active_filters, :params_to_remove

    def initialize(form:, has_active_filters: false, params_to_remove: [], request: nil)
      super()

      @form = form
      @has_active_filters = has_active_filters
      @params_to_remove = Array(params_to_remove).map(&:to_s)
      @request = request
    end

    def before_render
      request_helper = RequestHelper.new(current_request)
      @clear_url = request_helper.url_with_query({}, @params_to_remove)
    end

    def current_request
      @request || request
    end
  end
end
