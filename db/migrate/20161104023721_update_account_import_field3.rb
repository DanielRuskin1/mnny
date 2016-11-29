class UpdateAccountImportField3 < ActiveRecord::Migration[5.0]
  def change
    change_table :account_imports do |t|
      t.remove :csv_file
      t.text :csv_file
    end
  end
end
