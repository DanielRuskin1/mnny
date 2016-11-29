class BalanceRecordSets < ActiveRecord::Migration[5.0]
  def change
    create_table :balance_record_sets do |t|
      t.string :currency
      t.belongs_to :account
    end
    add_foreign_key :balance_record_sets, :accounts, on_delete: :cascade

    change_table :balance_records do |t|
      t.belongs_to :balance_record_set
    end
    add_foreign_key :balance_records, :balance_record_sets, on_delete: :cascade

    Account.all.each do |account|
      BalanceRecord.where(account_id: account.id).each do |br|
        balance_record_set = nil
        ActiveRecord::Base.with_advisory_lock(LockKeys.create_balance_record_set(account)) do
          balance_record_set = account.balance_record_sets.find_or_create_by({
            currency: account.currency
          })
        end

        br_new = balance_record_set.balance_records.new(
          effective_date: br.effective_date
        )
        br_new.balance = br.balance
        br_new.save!
        br_new.update_attributes(created_at: br.created_at)
      end
    end

    change_table :balance_records do |t|
      t.remove :account_id
    end

    change_table :accounts do |t|
      t.remove :currency
    end
  end
end
