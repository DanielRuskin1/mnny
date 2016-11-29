class HelpController < ApplicationController
  def submit
    email = current_user.try!(:email) || params[:email]
    subject = params[:subject]
    message = params[:message]

    if email.present? && subject.present? && message.present?
      UserMailer.help_request(email, subject, message).deliver

      @result = {
        error: false,
        message: "Help request submitted!  We'll get back to you within the next few hours."
      }
    else
      @result = {
        error: true,
        message: "It looks like some data was missing!  Please try again."
      }
    end
  end
end
