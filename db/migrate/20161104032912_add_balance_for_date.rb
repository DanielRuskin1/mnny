class AddBalanceForDate < ActiveRecord::Migration[5.0]
  def change
    change_table :balance_records do |t|
      t.datetime :effective_date
    end

    BalanceRecord.all.each do |balance_record|
      balance_record.update_attributes!(effective_date: balance_record.created_at)
    end

    change_column_null :balance_records, :effective_date, false
  end
end
