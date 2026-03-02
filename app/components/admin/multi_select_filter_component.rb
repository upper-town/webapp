module Admin
  class MultiSelectFilterComponent < ApplicationComponent
    DEFAULT_SELECT_CLASS = "#{ServersFilterComponent::DEFAULT_SELECT_CLASS} btn"

    attr_reader :form, :param_name, :selected_ids, :options, :placeholder, :apply_label, :all_label,
                :count_label, :count_label_one, :no_results_label, :aria_label, :select_class,
                :dropdown_id, :options_list_id

    # rubocop:disable Metrics/ParameterLists
    def initialize(
      form:,
      param_name:,
      options: [],
      selected_ids: [],
      placeholder: nil,
      apply_label: nil,
      all_label: nil,
      count_label: nil,
      count_label_one: nil,
      no_results_label: nil,
      aria_label: nil,
      select_class: nil,
      dropdown_id: nil,
      options_list_id: nil
    )
      super()

      @form = form
      @param_name = normalize_param_name(param_name)
      @selected_ids = normalize_ids(selected_ids)
      @options = options
      @placeholder = placeholder || I18n.t("admin.shared.filter_multiselect_placeholder")
      @apply_label = apply_label || I18n.t("admin.shared.filter_multiselect_apply")
      @all_label = all_label || I18n.t("admin.shared.filter_multiselect_all")
      # rubocop:disable Style/FormatStringToken
      @count_label = count_label || I18n.t("admin.shared.filter_multiselect_count.other")
      @count_label_one = count_label_one || I18n.t("admin.shared.filter_multiselect_count.one")
      # rubocop:enable Style/FormatStringToken
      @no_results_label = no_results_label || I18n.t("admin.shared.filter_multiselect_no_results")
      @aria_label = aria_label
      @select_class = select_class || DEFAULT_SELECT_CLASS
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

    def option_checked?(id)
      selected_ids.include?(id.to_s)
    end
  end
end
