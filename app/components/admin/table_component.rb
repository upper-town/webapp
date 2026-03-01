module Admin
  class TableComponent < ApplicationComponent
    include CopyableCell

    attr_reader :collection, :columns, :empty_message, :sort_column, :sort_direction, :sort_url_builder

    def initialize(
      collection: [],
      columns: [],
      empty_message: "No results",
      sort_column: nil,
      sort_direction: nil,
      sort_url_builder: nil
    )
      super()

      @collection = collection
      @columns = columns
      @empty_message = empty_message
      @sort_column = sort_column.presence
      @sort_direction = sort_direction.presence&.downcase
      @sort_url_builder = sort_url_builder
    end

    def sortable?(col)
      return false unless sort_url_builder
      return false unless (key = column_opts(col)&.dig(:sortable))

      key.present?
    end

    def sort_key(col)
      column_opts(col)&.dig(:sortable)
    end

    def sort_link_url(col)
      key = sort_key(col)
      return nil unless key

      next_direction = (sort_column == key) && sort_direction == "asc" ? "desc" : "asc"
      sort_url_builder.call(key, next_direction)
    end

    def sort_icon(col)
      key = sort_key(col)
      return nil unless key
      return nil unless sort_column == key

      sort_direction == "asc" ? "bi-sort-down-alt" : "bi-sort-up-alt"
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
      else
        column_opts[:copyable].to_s.presence
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
        value.presence
      when Proc
        column_value.call(item)
      end
    end

    def cell_with_copy_button(item, column_value, copy_val)
      content = cell_value(item, column_value)
      copy_cell_wrapper(content, copy_val)
    end

    def column_th_class(col)
      opts = column_opts(col)
      return "text-nowrap" unless opts

      align = opts[:align]
      base = "text-nowrap"
      case align
      when :end then "#{base} text-end"
      when :center then "#{base} text-center"
      else base
      end
    end

    def column_td_class(col)
      opts = column_opts(col)
      return "" unless opts

      align = opts[:align]
      case align
      when :end then "text-end"
      when :center then "text-center"
      else ""
      end
    end
  end
end
