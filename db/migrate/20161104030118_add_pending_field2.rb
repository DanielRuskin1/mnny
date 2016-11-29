class AddPendingField2 < ActiveRecord::Migration[5.0]
  def change
    change_table :account_imports do |t|
      t.remove :pending
      t.boolean :pending, default: true, null: false
    end
  end
end
