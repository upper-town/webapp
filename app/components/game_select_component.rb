class GameSelectComponent < ApplicationComponent
  attr_reader(
    :form,
    :only_in_use,
    :default_value,
    :selected_value,
    :blank_name,
    :select_class
  )

  def initialize(form, only_in_use: false, default_value: nil, selected_value: nil, blank_name: "All",
                 select_class: "form-select mb-2")
    super()

    @form = form
    @only_in_use = only_in_use
    @default_value = default_value
    @selected_value = selected_value
    @blank_name = blank_name
    @select_class = select_class

    @query = GameSelectOptionsQuery.new(only_in_use:)
  end

  def blank_option
    [blank_name, nil]
  end

  def options
    @options ||= @query.call
  end
end
