class TimeZoneSelectOptionsQuery
  include Callable

  def initialize(selected_time_zone: nil)
    @selected_time_zone = selected_time_zone
  end

  def call
    options = time_zone_options
    ensure_selected_in_options(options)
  end

  private

  def time_zone_options
    ActiveSupport::TimeZone.all.map { |tz| [tz.to_s, iana_identifier(tz)] }
  end

  def iana_identifier(zone)
    ActiveSupport::TimeZone::MAPPING[zone.name] || zone.tzinfo.name
  end

  def ensure_selected_in_options(options)
    return options if @selected_time_zone.blank?

    return options if options.any? { |_label, value| value == @selected_time_zone }

    zone = Time.find_zone(@selected_time_zone)
    return options unless zone

    [[zone.to_s, zone.tzinfo.name]] + options
  end
end
