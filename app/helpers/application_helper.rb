module ApplicationHelper
  def current_user
    return unless session[:user_id]
    @current_user ||= User.find(session[:user_id])
  end

  def set_title(title_to_set)
    content_for(:title, title_to_set.to_s)
  end

  def authentication_path
    if Rails.env.production?
      "/auth/google_oauth2"
    else
      "auth/developer"
    end
  end

  def render_object(object, params = {})
    case object
    when Account
      render("accounts/account", account: object)
    when BalanceRecord
      render("balance_record_sets/balance", balance_page: params[:balance_page], balance: object)
    when BalanceRecordSet
      balances = object
        .balance_records
        .order(effective_date: :desc)
        .order(created_at: :desc)
        .paginate(page: params[:balance_page], per_page: 5)
      render("balance_record_sets/balance_record_set", balance_page: params[:balance_page], balance_record_set: object, balances: balances)
    else
      raise NotImplementedError, object
    end
  end
end
