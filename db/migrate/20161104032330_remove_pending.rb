class RemovePending < ActiveRecord::Migration[5.0]
  def change
    change_table :account_imports do |t|
      t.remove :pending
    end
  end
end
