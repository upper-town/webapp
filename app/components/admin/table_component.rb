# frozen_string_literal: true

module Admin
  class TableComponent < ApplicationComponent
    def initialize(collection: [], columns: [], empty_message: "No results")
      super()

      @collection = collection
      @columns = columns
      @empty_message = empty_message
    end

    def empty?
      @collection.empty?
    end

    def column_name(col)
      col[0]
    end

    def column_value(col)
      col[1]
    end

    def column_opts(col)
      col[2] if col.is_a?(Array) && col.size >= 3
    end

    def show_copy?(col)
      column_opts(col)&.key?(:copyable)
    end

    def copyable_value(item, column_value, column_opts)
      return unless column_opts&.key?(:copyable)

      case column_opts[:copyable]
      when Symbol
        item.public_send(column_opts[:copyable]).to_s.presence
      when Proc
        column_opts[:copyable].call(item).to_s.presence
      when TrueClass
        raw = cell_raw_value(item, column_value)
        raw.to_s.presence if raw
      end
    end

    def cell_raw_value(item, column_value)
      case column_value
      when String
        column_value
      when Symbol
        item.public_send(column_value)
      when Proc
        nil # Cannot extract raw value from Proc
      end
    end

    def cell_value(item, column_value)
      case column_value
      when String
        column_value
      when Symbol
        value = item.public_send(column_value)
        value.presence || content_tag(:span, "--", class: "text-muted")
      when Proc
        column_value.call(item)
      end
    end

    def cell_with_copy_button(item, column_value, copy_val)
      content = cell_value(item, column_value)
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
