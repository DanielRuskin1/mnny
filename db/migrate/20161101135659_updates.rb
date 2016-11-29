class Updates < ActiveRecord::Migration[5.0]
  def change
    # Add hidden to BalanceRecord
    add_column :balance_records, :hidden, :boolean, default: false
    change_column_null :balance_records, :hidden, false

    # Monetize BalanceRecord
    change_table :balance_records do |t|
      t.remove :balance
      t.integer :balance_cents, null: false
    end
  end
end
