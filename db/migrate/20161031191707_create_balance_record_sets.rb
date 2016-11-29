class CreateBalanceRecordSets < ActiveRecord::Migration[5.0]
  def change
    create_table :balance_record_sets do |t|
      t.belongs_to :account, index: true

      t.timestamps
    end
  end
end
