module Admin
  class FetchableMultiSelectFilterComponent < ApplicationComponent
    attr_reader :form, :param_name, :selected_ids, :selected_labels, :static_options,
                :placeholder, :all_label, :count_label, :count_label_one, :no_results_label,
                :aria_label, :select_class, :input_id, :dropdown_id, :options_list_id,
                :search_url, :search_url_params, :min_chars, :min_chars_label, :loading_label

    # rubocop:disable Metrics/ParameterLists
    def initialize(
      form:,
      param_name:,
      selected_ids: [],
      selected_labels: [],
      static_options: [],
      placeholder: nil,
      all_label: nil,
      count_label: nil,
      count_label_one: nil,
      no_results_label: nil,
      aria_label: nil,
      select_class: nil,
      input_id: nil,
      dropdown_id: nil,
      options_list_id: nil,
      search_url:,
      search_url_params: {},
      min_chars: 2,
      min_chars_label: nil,
      loading_label: nil
    )
      super()

      @form = form
      @param_name = param_name.to_s.delete_suffix("[]")
      @selected_ids = Array(selected_ids).map(&:to_s).compact_blank
      @selected_labels = Array(selected_labels)
      @static_options = static_options
      @placeholder = placeholder || I18n.t("admin.shared.filter_multiselect_placeholder")
      @all_label = all_label || I18n.t("admin.shared.filter_multiselect_all")
      # rubocop:disable Style/FormatStringToken
      @count_label = count_label || I18n.t("admin.shared.filter_multiselect_count.other")
      @count_label_one = count_label_one || I18n.t("admin.shared.filter_multiselect_count.one")
      # rubocop:enable Style/FormatStringToken
      @no_results_label = no_results_label || I18n.t("admin.shared.filter_multiselect_no_results")
      @aria_label = aria_label
      @select_class = select_class || "form-select form-select-sm admin-servers-filter-inline__select btn"
      @input_id = input_id || "admin_fetchable_multi_select_filter_input_#{@param_name}"
      @dropdown_id = dropdown_id || "admin_fetchable_multi_select_filter_dropdown_#{@param_name}"
      @options_list_id = options_list_id || "admin_fetchable_multi_select_filter_options_#{@param_name}"
      @search_url = search_url
      @search_url_params = search_url_params
      @min_chars = min_chars
      @min_chars_label = min_chars_label
      @loading_label = loading_label
    end
    # rubocop:enable Metrics/ParameterLists

    def search_url_with_params
      return unless search_url.present?

      params = search_url_params.merge("target" => options_list_id)
      query = params.map { |k, v| "#{k}=#{ERB::Util.url_encode(v.to_s)}" }.join("&")
      "#{search_url}?#{query}"
    end

    def selected_options_from_labels
      lookup = selected_labels.to_h { |name, id| [id.to_s, [name, id]] }
      selected_ids.filter_map { |id| lookup[id] }
    end

    def trigger_text
      if selected_ids.empty?
        all_label
      elsif selected_ids.size == 1
        opts = selected_options_from_labels
        opts.one? ? opts.first.first : count_label_one
      else
        # rubocop:disable Style/FormatStringToken
        count_label.gsub("%{count}", selected_ids.size.to_s)
        # rubocop:enable Style/FormatStringToken
      end
    end

    def selected_labels_json
      selected_labels.to_json
    end

    def hidden_input_name
      "#{param_name}[]"
    end
  end
end
