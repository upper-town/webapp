module Inside
  class ServerCardComponent < ApplicationComponent
    attr_reader :server, :server_stats_hash, :period

    def initialize(server:, server_stats_hash:, period: Periods::MONTH)
      super()

      @server = server
      @server_stats_hash = server_stats_hash || {}
      @period = period
    end

    def render?
      @server.present?
    end

    def format_ranking_number(value)
      number = format_number(value)
      "#" + (number.nil? ? "--" : number)
    end

    def format_vote_count(value)
      number = format_number(value)
      number.nil? ? "--" : number
    end

    def stats
      @server_stats_hash[server.id] || {}
    end

    private

    def format_number(value)
      if value.nil? || value.negative?
        nil
      elsif value < 100_000
        number_with_delimiter(value)
      else
        number_to_human(
          value,
          precision: 4,
          format: "%n%u",
          units: { thousand: "k", million: "M", billion: "B", trillion: "T" }
        )
      end
    end
  end
end
