class User < ApplicationRecord
  has_many :accounts

  DEFAULT_BASE_CURRENCY = "USD"
  VALID_REMINDER_PERIODS = [nil, "daily", "weekly", "monthly"]
  VALID_BACKUP_PERIODS = [nil, "daily", "weekly", "monthly"]
  VALID_TIMEZONES = ActiveSupport::TimeZone.all.map(&:name)

  validates :timezone, inclusion: { in: User::VALID_TIMEZONES }
  validates :reminder_period, inclusion: { in: User::VALID_REMINDER_PERIODS }
  validates :base_currency, inclusion: { in: AssetPriceTracker::Asset.currencies_to_track.map(&:name) }
  validates :backup_period, inclusion: { in: User::VALID_BACKUP_PERIODS }
  validates :omniauth_uid, presence: true, allow_blank: false
  validates :email, email_format: { message: "is not looking good" }
  validates :name, presence: true, allow_blank: false

  def self.find_or_create_from_auth_hash!(auth_hash)
    User.create!(
      omniauth_uid: auth_hash[:uid],
      email: auth_hash[:info][:email],
      name: auth_hash[:info][:name],
      base_currency: DEFAULT_BASE_CURRENCY
    )
  rescue ActiveRecord::RecordNotUnique
    User.find_by(omniauth_uid: auth_hash[:uid])
  end

  def self.send_reminders
    ActiveRecord::Base.with_advisory_lock(LockKeys.send_reminders) do
      [
        ["daily", 1.day.ago],
        ["weekly", 1.week.ago],
        ["monthly", 1.month.ago]
      ].each do |type, threshold|
        User.where("reminder_period = ? AND last_reminder < ?", type, threshold).each do |user|
          UserMailer.reminder(user).deliver
          user.update_attributes!(last_reminder: Time.now)
        end
      end
    end

    true
  end

  def self.send_backups
    ActiveRecord::Base.with_advisory_lock(LockKeys.send_backups) do
      [
        ["daily", 1.day.ago],
        ["weekly", 1.week.ago],
        ["monthly", 1.month.ago]
      ].each do |type, threshold|
        User.where("backup_period = ? AND last_backup < ?", type, threshold).each do |user|
          UserMailer.backup(user, DataExporter.export(user)).deliver
          user.update_attributes!(last_backup: Time.now)
        end
      end
    end

    true
  end

  def has_balance_records?
    accounts.any? do |account|
      account.balance_record_sets.any? do |balance_record_set|
        balance_record_set.balance_records.any?
      end
    end
  end

  private

  def tracking_params
    { email: email }
  end
end
