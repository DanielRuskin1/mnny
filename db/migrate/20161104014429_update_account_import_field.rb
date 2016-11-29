class UpdateAccountImportField < ActiveRecord::Migration[5.0]
  def change
    change_table :account_imports do |t|
      t.remove :file
      t.json :csv_file
    end
  end
end
