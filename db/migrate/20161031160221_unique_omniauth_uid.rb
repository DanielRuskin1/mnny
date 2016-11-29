class UniqueOmniauthUid < ActiveRecord::Migration[5.0]
  def change
    add_index :users, [:omniauth_uid], unique: true
  end
end
