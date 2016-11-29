class AddUserSettings < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.string :timezone, null: false, default: "Eastern Time (US & Canada)"
      t.string :currency, null: false, default: "USD"
    end
  end
end
