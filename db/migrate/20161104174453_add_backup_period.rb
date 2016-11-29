class AddBackupPeriod < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.string :backup_period
      t.datetime :last_backup
    end
  end
end
