class BalanceRecord < ApplicationRecord
  MAX_RECORDS_PER_BALANCE_RECORD_SET = 100

  belongs_to :balance_record_set

  validates :amount, presence: true
  validates :effective_date, presence: true
  validate :one_balance_record_per_set_per_day
  validate :max_balance_records

  before_validation :set_to_beginning_of_day, on: :create

  def amount_formatted
    case balance_record_set.asset_type
    when :currency
      amount.to_money(balance_record_set.asset_name).format
    when :stock
      amount.to_s
    else
      raise NotImplementedError, balance_record_set.asset_type
    end
  end

  def set_to_beginning_of_day
    self.effective_date = effective_date
      .in_time_zone(balance_record_set.account.user.timezone)
      .beginning_of_day
  end

  def one_balance_record_per_set_per_day
    criteria = if id.present?
                 balance_record_set.balance_records.where("id != ? AND effective_date = ?", id, effective_date)
               else
                 balance_record_set.balance_records.where("effective_date = ?", effective_date)
               end
    if criteria.any?
      self.errors.add(:base, "It looks like there's already a balance record for this asset today.  Please delete it and try again.")
    end
  end

  def max_balance_records
    criteria = if id.present?
                 balance_record_set.balance_records.where("id != ?", id)
               else
                 balance_record_set.balance_records
               end
    if criteria.count >= MAX_RECORDS_PER_BALANCE_RECORD_SET
      self.errors.add(:base, "It looks like you've reached the limit for balance records for this asset!  Please contact support to have your limit raised.")
    end
  end

  def tracking_params
    { balance_record_set_id: balance_record_set.id, account_id: balance_record_set.account.id }
  end
end
