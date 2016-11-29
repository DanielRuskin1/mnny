class AccountImport < ApplicationRecord
  require "csv"

  VALID_CSV_HEADERS = ["date", "asset_type", "asset_name", "amount"]
  TIME_FORMAT = "%m/%d/%Y"

  belongs_to :account
  mount_uploader :csv_file, AccountImportUploader

  # Processes pending AccountImports and deletes all files from S3
  def self.process_pending_and_delete_orphaned_files
    ActiveRecord::Base.with_advisory_lock(LockKeys.process_account_imports) do
      AccountImport.all.each do |account_import|
        account_import.process!
      end

      fog = FogConnections.s3_connection
      bucket = fog.directories.new(key: ENV["CARRIER_WAVE_BUCKET_NAME"])

      bucket.files.each do |file|
        if file.key.starts_with?("uploads/")
          file.destroy
        end
      end
    end
  end

  class ImportFailedError < StandardError; end
  def process!
    transaction do
      begin
        parsed_csv = CSV.parse(csv_file.read)
      rescue CSV::MalformedCSVError
        fail_process!(:invalid_csv)
        raise ImportFailedError
      end

      headers = parsed_csv.first
      data = parsed_csv[1..-1]

      if headers != VALID_CSV_HEADERS
        fail_process!(:invalid_csv)
        raise ImportFailedError
      end

      data.each do |data_point|
        ActiveRecord::Base.with_advisory_lock(LockKeys.create_balance_record_set(account)) do
          begin
            parsed_time = Time.iso8601(data_point[0])
          rescue ArgumentError
            fail_process!(:invalid_time)
            raise ImportFailedError
          end
          asset_type = data_point[1]
          asset_name = data_point[2]
          amount = data_point[3]

          balance_record_set = account.balance_record_sets.find_or_create_by({
            asset_type: asset_type,
            asset_name: asset_name
          })
          if !balance_record_set.valid?
            fail_process!(:balance_record_set_error, balance_record_set.errors.join(" "))
            raise ImportFailedError
          end

          result = balance_record_set.balance_records.create({ effective_date: parsed_time, amount: amount })
          if !result
            fail_process!(:balance_record_error, result.errors.join(" "))
            raise ImportFailedError
          end
        end
      end

      succeed_process!(data)
    end
  rescue ImportFailedError
    false
  end

  private

  def fail_process!(reason, data = nil)
    UserMailer.account_import_failed(account.user, reason, data).deliver
    destroy!
  end

  def succeed_process!(data)
    UserMailer.account_import_success(account.user, data.count).deliver
    destroy!
  end

  def tracking_params
    { account_id: account.id }
  end
end
