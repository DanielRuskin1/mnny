class AddBalanceSetHidden < ActiveRecord::Migration[5.0]
  def change
    add_column :balance_record_sets, :hidden, :boolean, default: false
    change_column_null :balance_record_sets, :hidden, false
  end
end
