module Search
  module ByRemoteIp
    REMOTE_IP_PATTERN = /\A[\d.]+\z/

    private

    def match_remote_ip?
      term.match?(REMOTE_IP_PATTERN)
    end

    def by_remote_ip(table_column)
      if match_remote_ip?
        base_model.where("#{sanitized_table_column(table_column)} ILIKE ?", term_for_like)
      else
        base_model.none
      end
    end
  end
end
