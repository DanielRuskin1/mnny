class AaddTimestamps < ActiveRecord::Migration[5.0]
  def change
    change_table :balance_record_sets do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end

    BalanceRecordSet.all.each do |balance_record_set|
      balance_record_set.update_attributes!(created_at: Time.now, updated_at: Time.now)
    end

    change_column_null :balance_record_sets, :created_at, false
    change_column_null :balance_record_sets, :updated_at, false
  end
end
