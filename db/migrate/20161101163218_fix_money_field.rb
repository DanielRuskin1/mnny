class FixMoneyField < ActiveRecord::Migration[5.0]
  def change
    change_table :balance_records do |t|
      t.remove :balance_cents
      t.money :balance
    end
  end
end
