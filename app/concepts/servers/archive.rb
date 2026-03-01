module Servers
  class Archive
    include Callable

    attr_reader :server

    def initialize(server)
      @server = server
    end

    def call
      if server.archived?
        Result.failure(I18n.t("servers.errors.already_archived"))
      else
        server.update!(archived_at: Time.current)

        Result.success
      end
    end
  end
end
