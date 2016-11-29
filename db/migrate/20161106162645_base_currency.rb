class BaseCurrency < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.string :base_currency
    end

    User.all.each do |user|
      currency_to_set = nil
      user.accounts.each do |account|
        account.balance_record_sets.each do |balance_record_set|
          currency_to_set ||= balance_record_set.currency
        end
      end
      currency_to_set ||= "USD"

      user.update_attributes!(base_currency: currency_to_set)
    end

    change_column_null :users, :base_currency, false

    # Misc fix from last migration
    change_column_null :balance_record_sets, :currency, false
  end
end
