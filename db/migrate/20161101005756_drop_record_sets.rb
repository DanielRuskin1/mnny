class DropRecordSets < ActiveRecord::Migration[5.0]
  def change
    drop_table :balance_record_sets
    change_table :balance_records do |t|
      t.remove :balance_record_set_id
      t.belongs_to :account, index: true
    end
  end
end
