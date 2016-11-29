class AddReminders < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.string :reminder_period
      t.datetime :last_reminder
    end
  end
end
