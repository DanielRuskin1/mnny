namespace :backups do
  desc "Send backups to users."
  task send: :environment do
    User.send_backups
  end
end
