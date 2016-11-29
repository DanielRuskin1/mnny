class FixCurrency2 < ActiveRecord::Migration[5.0]
  def change
    change_table :accounts do |t|
      t.remove :currency
      t.string :currency, null: false
    end
  end
end
