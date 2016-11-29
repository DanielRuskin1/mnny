# Returns a CSV file representing all of the user's data.
class DataExporter
  require 'csv'

  def self.file_name
    "Mnny-Export.csv"
  end

  def self.export(user)
    CSV.generate(headers: true) do |csv|
      # Export user info
      csv << ["user"]
      csv << ["id", "auth_id", "name", "email"]
      csv << [user.id, user.omniauth_uid, user.name, user.email]
      csv << [""]

      # Export account info
      csv << ["accounts"]
      csv << ["id", "name"]
      user.accounts.each do |account|
        csv << [account.id, account.name]
      end
      csv << [""]

      # Export balance records
      csv << ["balance_records"]
      csv << ["id", "recorded_at", "account_id", "currency", "asset_type", "asset_name", "amount"]
      user.accounts.each do |account|
        account.balance_record_sets.each do |balance_record_set|
          balance_record_set.balance_records.each do |balance_record|
            csv << [
              balance_record.id,
              balance_record.created_at,
              balance_record_set.account_id,
              balance_record_set.asset_type,
              balance_record_set.asset_name,
              balance_record.amount
            ]
          end
        end
      end
    end
  end
end
