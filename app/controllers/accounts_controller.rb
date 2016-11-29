class AccountsController < ApplicationController
  before_action :require_current_user

  def index
    get_accounts(params[:page])
  end

  def start_import
    @account = current_user.accounts.find(params[:id])

    @uploader = @account.account_imports.new.csv_file
    @uploader.success_action_redirect = import_complete_account_url(@account)
  end

  def import_complete
    account = current_user.accounts.find(params[:id])

    # Set manually to use key setter
    ai = account.account_imports.new
    ai.key = params[:key]
    ai.save!

    redirect_to(accounts_path, flash: { success: "Import started!  You'll receive an email once it has been processed.  This typically takes 5-10 minutes." })
  end

  def create
    ActiveRecord::Base.with_advisory_lock(LockKeys.create_account(current_user)) do
      current_user.reload

      @account = current_user.accounts.create(account_params)

      if @account.errors.any?
        @result = {
          error: true,
          message: "Error!  " + @account.errors.full_messages.join(", ")
        }
      else
        @result = {
          error: false,
          message: "Account created!"
        }
        get_accounts(1)
      end
    end
  end

  def destroy
    current_user.accounts.find(params[:id]).destroy

    # Go back to closest page that still has accounts
    page = [params[:page].to_i, 1].max
    get_accounts(page)
    while @accounts.empty? && page != 1
      get_accounts(page)
      page = page - 1
    end
  end

  private

  def get_accounts(page)
    @accounts = current_user
      .accounts
      .order(created_at: :desc)
      .paginate(page: page, per_page: 10)
  end

  def account_params
    params.require(:account).permit(:name)
  end
end
