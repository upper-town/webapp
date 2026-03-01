class PaginationCursorComponent < ApplicationComponent
  DEFAULT_OPTIONS = {
    show_first: true,
    show_goto:  false,

    show_total_pages: false, # This calls pagination's total_count
    show_per_page:    false,
    show_total_count: false, # This calls pagination's total_count

    first_icon: nil,
    prev_icon:  nil,
    next_icon:  nil,
    go_icon:    nil
  }

  attr_reader :pagination_cursor, :options

  def initialize(pagination_cursor, **options)
    super()

    @pagination_cursor = pagination_cursor
    @options = DEFAULT_OPTIONS.merge(options)
  end

  def show_badges?
    show_total_pages? || show_per_page? || show_total_count?
  end

  def show_first?
    options[:show_first]
  end

  def show_goto?
    options[:show_goto]
  end

  def show_total_pages?
    options[:show_total_pages]
  end

  def show_per_page?
    options[:show_per_page]
  end

  def show_total_count?
    options[:show_total_count]
  end

  def first_icon
    options[:first_icon] || I18n.t("shared.pagination.first")
  end

  def prev_icon
    options[:prev_icon] || I18n.t("shared.pagination.prev")
  end

  def next_icon
    options[:next_icon] || I18n.t("shared.pagination.next")
  end

  def go_icon
    options[:go_icon] || I18n.t("shared.pagination.go")
  end
end
