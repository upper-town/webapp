module Admin
  class DetailsTableComponent < ApplicationComponent
    include CopyableCell

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
      copy_cell_wrapper(content, copy_val)
    end
  end
end
