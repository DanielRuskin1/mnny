class CreateBalanceRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :balance_records do |t|
      t.float :balance, null: false
      t.belongs_to :balance_record_set, index: true

      t.timestamps
    end
  end
end
