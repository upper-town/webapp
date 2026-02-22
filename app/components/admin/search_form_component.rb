# frozen_string_literal: true

module Admin
  class SearchFormComponent < ApplicationComponent
    attr_reader :url, :search_term, :placeholder, :param, :hidden_params

    def initialize(url:, search_term: nil, placeholder: nil, param: :q, hidden_params: {})
      super()

      @url = url
      @search_term = search_term
      @placeholder = placeholder || t("admin.shared.search_placeholder")
      @param = param
      @hidden_params = hidden_params.compact
    end

    def clear_url
      base = url.to_s
      return base if hidden_params.empty?

      separator = base.include?("?") ? "&" : "?"
      "#{base}#{separator}#{Rack::Utils.build_nested_query(hidden_params)}"
    end

    def show_clear?
      search_term.present?
    end
  end
end
