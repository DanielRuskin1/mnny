class LockKeys
  def self.send_reminders
    "send_reminders"
  end

  def self.send_backups
    "send_backups"
  end

  def self.process_account_imports
    "process_account_imports"
  end

  def self.track_asset_prices
    "track_asset_prices"
  end

  def self.process_job_requests
    "process_job_requests"
  end

  def self.create_account(user)
    "create_account_#{user.id}"
  end

  def self.create_balance_record_set(account)
    "create_balance_record_set_#{account.id}"
  end

  def self.create_balance_record_for_balance_record_set(balance_record_set)
    "create_balance_record_#{balance_record_set.id}"
  end
end
