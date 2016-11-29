namespace :reminders do
  desc "Send reminders to users."
  task send: :environment do
    User.send_reminders
  end
end
