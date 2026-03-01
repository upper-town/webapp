module Servers
  class MarkForDeletion
    include Callable

    attr_reader :server

    def initialize(server)
      @server = server
    end

    def call
      if server.not_archived?
        Result.failure(I18n.t("servers.errors.must_be_archived"))
      elsif server.marked_for_deletion?
        Result.failure(I18n.t("servers.errors.already_marked_for_deletion"))
      else
        server.update!(marked_for_deletion_at: Time.current)

        Result.success
      end
    end
  end
end
