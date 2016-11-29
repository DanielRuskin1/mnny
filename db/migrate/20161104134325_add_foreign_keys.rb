class AddForeignKeys < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :account_imports, :accounts, on_delete: :cascade
    add_foreign_key :balance_records, :accounts, on_delete: :cascade
    add_foreign_key :accounts, :users, on_delete: :cascade
  end
end
