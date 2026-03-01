module MailerTestSetup
  def setup
    super

    ActionMailer::Base.deliveries.clear
  end
end
