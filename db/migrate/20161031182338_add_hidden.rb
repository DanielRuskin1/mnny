class AddHidden < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :hidden, :boolean, default: false
    change_column_null :accounts, :hidden, false
  end
end
