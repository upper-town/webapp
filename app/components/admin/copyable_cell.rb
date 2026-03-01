module Admin
  module CopyableCell
    def copy_button_html
      content_tag(:button, type: "button", class: "btn btn-link btn-sm p-0 text-body-secondary border-0",
        title: I18n.t("admin.shared.copy_to_clipboard"),
        aria: { label: I18n.t("admin.shared.copy_to_clipboard") },
        data: { copy_btn: true, action: "click->copy-to-clipboard#copy" }) do
        clipboard_icon
      end
    end

    def clipboard_icon
      tag.i(class: "bi bi-clipboard flex-shrink-0 admin-copy-icon", "aria-hidden": "true")
    end

    def copy_cell_wrapper(display_content, copy_value)
      data_attrs = { controller: "copy-to-clipboard", copied_title: I18n.t("admin.shared.copied") }
      data_attrs[:copy_to_clipboard_value] = copy_value if copy_value.present?
      content_target_value = copy_value.presence

      content_tag(:span, class: "d-inline-flex align-items-center gap-1", data: data_attrs) do
        parts = []
        if content_target_value.present?
          parts << content_tag(:span, content_target_value, data: { copy_to_clipboard_target: "content" }, class: "visually-hidden")
        end
        content_data = content_target_value.present? ? {} : { copy_to_clipboard_target: "content" }
        parts << content_tag(:span, display_content, data: content_data)
        safe_join(parts + [copy_button_html])
      end
    end
  end
end
