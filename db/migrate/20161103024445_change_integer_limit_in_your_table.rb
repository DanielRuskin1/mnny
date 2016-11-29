class ChangeIntegerLimitInYourTable < ActiveRecord::Migration[5.0]
  def change
    change_column :balance_records, :balance_cents, :integer, limit: 8
  end
end
