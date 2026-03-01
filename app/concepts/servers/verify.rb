module Servers
  class Verify
    include Callable

    attr_reader :server

    def initialize(server, current_time = Time.current)
      @server = server
      @current_time = current_time
    end

    def call
      result = VerifyAccounts::Perform.call(server, @current_time)

      if result.success?
        update_as_verified(@current_time)
      else
        update_as_not_verified(result)
      end
    end

    private

    def update_as_verified(current_time)
      server.update!(
        verified_at: current_time,
        metadata: {}
      )
    end

    def update_as_not_verified(result)
      notice = result.errors.full_messages.join("; ")

      server.update!(
        verified_at: nil,
        metadata: { notice: }
      )
    end
  end
end
