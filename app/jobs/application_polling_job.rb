class ApplicationPollingJob < ActiveJob::Base
  queue_as "default"
end
