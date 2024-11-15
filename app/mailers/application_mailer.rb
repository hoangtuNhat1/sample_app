class ApplicationMailer < ActionMailer::Base
  default from: Settings.mail_name
  layout "mailer"
end
