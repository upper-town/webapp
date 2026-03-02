class PeriodSelectComponent < ApplicationComponent
  attr_reader(:form, :default_value, :selected_value, :select_class)

  def initialize(form, default_value: Periods::MONTH, selected_value: nil, select_class: "form-select mb-2")
    super()

    @form = form
    @default_value = default_value
    @selected_value = selected_value
    @select_class = select_class

    @query = PeriodSelectOptionsQuery.new
  end

  def options
    @options ||= @query.call
  end
end
