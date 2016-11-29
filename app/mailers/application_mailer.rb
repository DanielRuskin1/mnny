class ApplicationMailer < ActionMailer::Base
  default from: ENV["SEND_FROM_EMAIL"]
  layout "mailer"
end
