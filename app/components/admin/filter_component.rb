module Admin
  class FilterComponent < ApplicationComponent
    attr_reader :form, :params_to_remove, :request_helper, :passed_request

    def initialize(form:, params_to_remove: [], request: nil)
      super()

      @form = form
      @params_to_remove = normalize_ids(params_to_remove)
      @passed_request = request
    end

    def before_render
      @request_helper = RequestHelper.new(current_request)
    end

    def current_request
      passed_request || request
    end
  end
end
