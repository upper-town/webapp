class CountrySelectComponent < ApplicationComponent
  attr_reader(
    :form,
    :only_in_use,
    :with_continents,
    :blank_name,
    :selected_value,
    :select_class,
    :aria_label,
    :param_name
  )

  def initialize(
    form,
    only_in_use: false,
    with_continents: false,
    blank_name: "All",
    selected_value: nil,
    select_class: "form-select mb-2",
    aria_label: nil,
    param_name: "country_code"
  )
    super()

    @form = form
    @only_in_use = only_in_use
    @with_continents = with_continents
    @blank_name = blank_name
    @selected_value = selected_value
    @select_class = select_class
    @aria_label = aria_label
    @param_name = param_name

    @query = CountrySelectOptionsQuery.new(only_in_use:, with_continents:)
  end

  def blank_option
    [blank_name, nil]
  end

  def options
    @options ||= @query.call
  end

  def select_html_options
    opts = {
      class: select_class,
      data: { "controller" => "country-select" }
    }
    opts["aria-label"] = aria_label if aria_label.present?
    opts["name"] = "#{param_name}[]" if param_name == "country_codes"
    opts
  end
end
