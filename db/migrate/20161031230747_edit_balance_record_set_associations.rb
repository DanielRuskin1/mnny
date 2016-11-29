class EditBalanceRecordSetAssociations < ActiveRecord::Migration[5.0]
  def change
    change_table :balance_record_sets do |t|
      t.remove :account_id
      t.belongs_to :user, index: true
    end
  end
end
