module Servers
  class VerifyJob < ApplicationJob
    def perform(server)
      Verify.call(server)
    end
  end
end
