class StocksBonds < ActiveRecord::Migration[5.0]
  def change
    change_table :balance_record_sets do |t|
      t.string :asset_type
      t.string :asset_name
    end

    BalanceRecordSet.all.each do |record_set|
      record_set.update_attributes!(asset_type: :currency, asset_name: record_set.currency)
    end

    change_table :balance_record_sets do |t|
      t.remove :currency
    end
    change_column_null :balance_record_sets, :asset_type, false
    change_column_null :balance_record_sets, :asset_name, false

    change_table :balance_records do |t|
      t.float :amount
    end
    BalanceRecord.all.each do |balance_record|
      balance_record.update_attributes!(amount: balance_record.balance_cents / 100)
    end
    change_table :balance_records do |t|
      t.remove_monetize :balance
    end
    change_column_null :balance_records, :amount, false
  end
end
