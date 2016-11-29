class FixMoneyField2 < ActiveRecord::Migration[5.0]
  def change
    change_table :balance_records do |t|
      t.remove :balance
      t.monetize :balance
    end
  end
end
