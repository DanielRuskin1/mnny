class AddColor < ActiveRecord::Migration[5.0]
  def change
    change_table :accounts do |t|
      t.string :color, null: false
    end
  end
end
