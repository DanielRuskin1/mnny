class FixCurrency < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.remove :currency
    end

    change_table :accounts do |t|
      t.string :currency, null: false, default: "USD"
    end
  end
end
