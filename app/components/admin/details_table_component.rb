# frozen_string_literal: true

module Admin
  class DetailsTableComponent < ApplicationComponent
    attr_reader :sections

    def initialize(sections: [])
      super()

      @sections = sections
    end

    def row_value(value)
      case value
      when nil, ""
        content_tag(:span, "--", class: "text-muted")
      when Proc
        value.call
      else
        value
      end
    end

    def key_value_row?(row)
      row.is_a?(Array) && row.size >= 2
    end

    def full_width_row?(row)
      row.is_a?(Array) && row.size == 1
    end

    def show_copy_for_row?(row)
      opts = row[2].is_a?(Hash) ? row[2] : {}
      opts.key?(:copy_value) || opts.key?(:copyable)
    end

    def copy_value_for_row(row)
      opts = row[2].is_a?(Hash) ? row[2] : {}
      return opts[:copy_value].to_s if opts.key?(:copy_value)
      return unless opts[:copyable]

      val = row[1]
      case val
      when Proc, nil, ""
        nil
      else
        val.to_s
      end
    end

    def value_cell_with_copy(row)
      content = row_value(row[1])
      copy_val = copy_value_for_row(row)
      data_attrs = { controller: "copy-to-clipboard", copied_title: I18n.t("admin.shared.copied") }
      data_attrs[:copy_to_clipboard_value] = copy_val if copy_val.present?
      # When we have an explicit copy value, put it in a hidden span as content target so fallback copies only the value
      content_target_value = copy_val.present? ? copy_val : nil

      content_tag(:span, class: "d-inline-flex align-items-center gap-1", data: data_attrs) do
        parts = []
        parts << content_tag(:span, content_target_value, data: { copy_to_clipboard_target: "content" }, class: "visually-hidden") if content_target_value.present?
        parts << content_tag(:span, content, data: (content_target_value.present? ? {} : { copy_to_clipboard_target: "content" }))
        safe_join(parts + [copy_button_html])
      end
    end

    def copy_button_html
      content_tag(:button, type: "button", class: "btn btn-link btn-sm p-0 text-muted border-0",
        title: I18n.t("admin.shared.copy_to_clipboard"),
        data: { copy_btn: true, action: "click->copy-to-clipboard#copy" }) do
        clipboard_icon
      end
    end

    def clipboard_icon
      tag.i(class: "bi bi-clipboard flex-shrink-0", style: "font-size: 0.875rem")
    end
  end
end
