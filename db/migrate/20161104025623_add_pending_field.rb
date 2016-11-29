class AddPendingField < ActiveRecord::Migration[5.0]
  def change
    change_table :account_imports do |t|
      t.boolean :pending, default: false, null: false
    end
  end
end
