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
        nil
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
      opts.key?(:copyable)
    end

    def copy_value_for_row(row)
      opts = row[2].is_a?(Hash) ? row[2] : {}
      copyable = opts[:copyable]
      return unless copyable

      case copyable
      when TrueClass
        val = row[1]
        (val.is_a?(Proc) || val.nil? || val == "") ? nil : val.to_s
      when Proc
        copyable.call.to_s.presence
      else
        copyable.to_s.presence
      end
    end

    def value_cell_with_copy(row)
      content = row_value(row[1])
      copy_val = copy_value_for_row(row)
      data_attrs = { controller: "copy-to-clipboard", copied_title: I18n.t("admin.shared.copied") }
      data_attrs[:copy_to_clipboard_value] = copy_val if copy_val.present?
      # When we have an explicit copy value, put it in a hidden span as content target so fallback copies only the value
      content_target_value = (copy_val.presence)

      content_tag(:span, class: "d-inline-flex align-items-center gap-1", data: data_attrs) do
        parts = []
        if content_target_value.present?
          parts << content_tag(:span, content_target_value, data: { copy_to_clipboard_target: "content" },
class: "visually-hidden")
        end
        parts << content_tag(:span, content,
data: (content_target_value.present? ? {} : { copy_to_clipboard_target: "content" }))
        safe_join(parts + [copy_button_html])
      end
    end

    def copy_button_html
      content_tag(:button, type: "button", class: "btn btn-link btn-sm p-0 text-body-secondary border-0",
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
