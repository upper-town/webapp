module Servers
  class VerifyJob < ApplicationJob
    def perform(server)
      Verify.new(server).call
    end
  end
end
