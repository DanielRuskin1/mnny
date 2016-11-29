class BalanceRecordSetsController < ApplicationController
  before_action :require_current_user

  def show
    @balance_record_set = find_balance_record_set(params[:id])
    @balance_page = params[:page]
  end

  def create
    # Extract account_id from params
    @account = current_user
      .accounts
      .find(balance_record_set_create_params[:account_id])

    ActiveRecord::Base.with_advisory_lock(LockKeys.create_balance_record_set(@account)) do
      balance_record_set = @account.balance_record_sets.create(balance_record_set_create_params.except(:account_id))

      if balance_record_set.errors.any?
        @result = {
          error: true,
          message: "Error!  " + balance_record_set.errors.full_messages.join(", ")
        }
      else
        @result = {
          error: false,
          message: "Asset created!"
        }
      end
    end
  end

  def destroy
    balance_record_set = find_balance_record_set(params[:id])
    @account = balance_record_set.account

    balance_record_set.destroy
    @account.reload # Refresh relations to not have now-destroyed BalanceRecordSet
  end

  def create_balance_record
    @balance_record_set = find_balance_record_set(params[:id])

    ActiveRecord::Base.with_advisory_lock(LockKeys.create_balance_record_for_balance_record_set(@balance_record_set)) do
      balance_record = @balance_record_set.balance_records.new(create_balance_record_params.except(:balance_record_set_id, :balance, :effective_date))
      balance_record.effective_date = ActiveSupport::TimeZone[current_user.timezone].strptime(
        create_balance_record_params[:effective_date],
        "%m/%d/%Y"
      ) unless create_balance_record_params[:effective_date].nil?
      begin
        balance_record.amount = Float(create_balance_record_params[:amount])
      rescue ArgumentError
        # There will be an error
      end
      balance_record.save

      if balance_record.errors.any?
        @result = {
          error: true,
          message: "Error!  " + balance_record.errors.full_messages.join(", ")
        }
      else
        @result = {
          error: false,
          message: "Balance record created!"
        }
        @balance_page = [params[:page].to_i, 1].max
      end
    end
  end

  def destroy_balance_record
    @balance_record_set = find_balance_record_set(params[:id])

    @balance_record_set
      .balance_records
      .find(destroy_balance_record_params[:id])
      .destroy
    @balance_record_set.reload # Reload relations for re-render

    # Go back to closest page that still has accounts
    @balance_page = [params[:page].to_i, 1].max
    balance_records = []
    while balance_records.empty? && @balance_page != 1
      balance_records = @balance_record_set.balance_records.paginate(page: @balance_page, per_page: 5)
      @balance_page = @balance_page - 1
    end
  end

  private

  def balance_record_set_create_params
    params.require(:balance_record_set).permit(:account_id, :asset_type, :asset_name)
  end

  def create_balance_record_params
    params.require(:balance_record).permit(:amount, :effective_date)
  end

  def destroy_balance_record_params
    params.require(:balance_record).permit(:id)
  end

  def find_balance_record_set(id)
    current_user.accounts.each do |account|
      account.balance_record_sets.each do |balance_record_set|
        if balance_record_set.id.to_s == id
          return balance_record_set
        end
      end
    end

    raise ActiveRecord::RecordNotFound
  end
end
