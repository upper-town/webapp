class PaginationComponent < ApplicationComponent
  DEFAULT_OPTIONS = {
    show_first: true,
    show_last:  false, # This calls pagination's total_count
    show_goto:  true,

    show_page:        false,
    show_total_pages: false, # This calls pagination's total_count
    show_per_page:    false,
    show_total_count: false, # This calls pagination's total_count

    first_icon: nil,
    last_icon:  nil,
    prev_icon:  nil,
    next_icon:  nil,
    go_icon:    nil,

    align: :center # :center or :start
  }

  attr_reader :pagination, :options

  def initialize(pagination, **options)
    super()

    @pagination = pagination
    @options = DEFAULT_OPTIONS.merge(options)
  end

  def show_badges?
    show_page? || show_total_pages? || show_per_page? || show_total_count?
  end

  def show_first?
    options[:show_first]
  end

  def show_last?
    options[:show_last]
  end

  def show_goto?
    options[:show_goto]
  end

  def show_page?
    options[:show_page]
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

  def last_icon
    options[:last_icon] || I18n.t("shared.pagination.last")
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

  def align_start?
    options[:align] == :start
  end

  def wrapper_justify_class
    align_start? ? "justify-content-start" : "justify-content-center"
  end
end
