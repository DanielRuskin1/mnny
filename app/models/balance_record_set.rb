class BalanceRecordSet < ApplicationRecord
  MAX_BALANCE_RECORD_SETS = 10

  belongs_to :account
  has_many :balance_records

  validate :valid_asset
  validate :one_per_asset_per_account
  validate :max_balance_record_sets

  # Helper to simulate symbol storage
  def asset_type
    super.try!(:to_sym)
  end

  def asset_type=(value)
    super(value.try!(:to_sym))
  end

  def valid_asset
    unless AssetPriceTracker::Asset.new(asset_type, asset_name).valid?
      self.errors.add(:base, "It looks like we don't support that asset yet!  Shoot us over an email if you'd like to see it added.")
    end
  end

  def one_per_asset_per_account
    criteria = if id.present?
                 account.balance_record_sets.where("id != ? AND asset_type = ? AND asset_name = ?", id, asset_type, asset_name)
               else
                 account.balance_record_sets.where("asset_type = ? AND asset_name = ?", asset_type, asset_name)
               end
    if criteria.any?
      self.errors.add(:base, "It looks like you've already added this asset!")
    end
  end

  def max_balance_record_sets
    criteria = if id.present?
                 account.balance_record_sets.where("id != ?", id)
               else
                 account.balance_record_sets
               end
    if criteria.count >= MAX_BALANCE_RECORD_SETS
      self.errors.add(:base, "It looks like you've reached the limit for assets!  Please contact support to have your limit raised.")
    end
  end

  def most_recent_balance_record
    balance_records
      .order(effective_date: :desc)
      .order(created_at: :desc)
      .first
  end

  def tracking_params
    { account_id: account.id, asset_type: asset_type, asset_name: asset_name }
  end
end
