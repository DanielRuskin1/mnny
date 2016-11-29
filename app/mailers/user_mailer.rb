class UserMailer < ApplicationMailer
  def reminder(user)
    @name = user.name
    mail(to: user.email, subject: "It's time to update your net worth!")
  end

  def backup(user, data)
    @name = user.name
    attachments[DataExporter.file_name] = data
    mail(to: user.email, subject: "Your Mnny backup is ready!")
  end

  def account_import_failed(user, reason, data)
    @name = user.name
    @reason = reason
    @data = data
    mail(to: user.email, subject: "Account Import Failed")
  end

  def account_import_success(user, count)
    @name = user.name
    @count = count
    mail(to: user.email, subject: "Account Import Succeeded!")
  end

  def help_request(email, subject, message)
    @email = email
    @subject = subject
    @message = message

    mail(to: ENV["SUPPORT_EMAIL"], subject: "Support Request Received")
  end
end
