# frozen_string_literal: true

module ServersHelper
  def format_server_ranking(value)
    number = format_server_number(value)
    "##{number.nil? ? '--' : number}"
  end

  def format_server_vote_count(value)
    number = format_server_number(value)
    number.nil? ? "--" : number
  end

  private

  def format_server_number(value)
    return nil if value.nil? || value.negative?

    if value < 100_000
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
