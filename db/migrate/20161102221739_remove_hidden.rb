class RemoveHidden < ActiveRecord::Migration[5.0]
  def change
    change_table :accounts do |t|
      t.remove :hidden
    end

    change_table :balance_records do |t|
      t.remove :hidden
    end
  end
end
