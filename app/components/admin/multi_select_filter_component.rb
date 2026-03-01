module Admin
  class MultiSelectFilterComponent < ApplicationComponent
    attr_reader :form, :param_name, :selected_ids, :options, :placeholder, :all_label, :count_label,
                :count_label_one, :no_results_label, :aria_label, :select_class, :input_id, :dropdown_id,
                :options_list_id

    # rubocop:disable Metrics/ParameterLists
    def initialize(
      form:,
      param_name:,
      options: [],
      selected_ids: [],
      placeholder: nil,
      all_label: nil,
      count_label: nil,
      count_label_one: nil,
      no_results_label: nil,
      aria_label: nil,
      select_class: nil,
      input_id: nil,
      dropdown_id: nil,
      options_list_id: nil
    )
      super()

      @form = form
      @param_name = param_name.to_s.delete_suffix("[]")
      @selected_ids = Array(selected_ids).map(&:to_s).compact_blank
      @options = options
      @placeholder = placeholder || I18n.t("admin.shared.filter_multiselect_placeholder")
      @all_label = all_label || I18n.t("admin.shared.filter_multiselect_all")
      # rubocop:disable Style/FormatStringToken
      @count_label = count_label || I18n.t("admin.shared.filter_multiselect_count.other")
      @count_label_one = count_label_one || I18n.t("admin.shared.filter_multiselect_count.one")
      # rubocop:enable Style/FormatStringToken
      @no_results_label = no_results_label || I18n.t("admin.shared.filter_multiselect_no_results")
      @aria_label = aria_label
      @select_class = select_class || "form-select form-select-sm admin-servers-filter-inline__select btn"
      @input_id = input_id || "admin_multi_select_filter_input_#{@param_name}"
      @dropdown_id = dropdown_id || "admin_multi_select_filter_dropdown_#{@param_name}"
      @options_list_id = options_list_id || "admin_multi_select_filter_options_#{@param_name}"
    end
    # rubocop:enable Metrics/ParameterLists

    def options_json
      options.to_json
    end

    def selected_options
      selected_ids.filter_map { |id| options.find { |_name, opt_id| opt_id.to_s == id } }
    end

    def trigger_text
      if selected_ids.empty?
        all_label
      elsif selected_ids.size == 1
        opts = selected_options
        opts.one? ? opts.first.first : count_label_one
      else
        # rubocop:disable Style/FormatStringToken
        count_label.gsub("%{count}", selected_ids.size.to_s)
        # rubocop:enable Style/FormatStringToken
      end
    end

    def hidden_input_name
      "#{param_name}[]"
    end
  end
end
