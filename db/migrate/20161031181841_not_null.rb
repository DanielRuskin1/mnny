class NotNull < ActiveRecord::Migration[5.0]
  def change
    change_column_null :users, :omniauth_uid, false
    change_column_null :users, :email, false
    change_column_null :users, :name, false

    change_column_null :accounts, :name, false
  end
end
