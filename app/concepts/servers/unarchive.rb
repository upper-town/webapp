module Servers
  class Unarchive
    attr_reader :server

    def initialize(server)
      @server = server
    end

    def call
      if server.marked_for_deletion?
        Result.failure(I18n.t("servers.errors.marked_for_deletion_unmark_first"))
      elsif server.not_archived?
        Result.failure(I18n.t("servers.errors.not_archived"))
      else
        server.update!(archived_at: nil)

        Result.success
      end
    end
  end
end
