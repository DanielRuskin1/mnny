class CreateAccountImports < ActiveRecord::Migration[5.0]
  def change
    create_table :account_imports do |t|
      t.json :file
      t.belongs_to :account, index: true

      t.timestamps
    end
  end
end
