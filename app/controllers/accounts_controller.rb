class AccountsController < ApplicationController
  def show
    @connection = Connection.find(params[:connection_id])
    @account = @connection.accounts.find(params[:id])
  end

  def edit
    @connection = Connection.find(params[:connection_id])
    @account = @connection.accounts.find(params[:id])
  end
  
  def update
    @connection = Connection.find(params[:connection_id])
    @account = @connection.accounts.find(params[:id])
 
    if @account.update(account_params)
      redirect_to connection_account_path(@connection, @account)
    else
      render 'edit'
    end
  end

  def sync_transactions
    @connection = Connection.find(params[:connection_id])
    @account = @connection.accounts.find(params[:id])
    AccountsController.do_sync_transactions(@connection, @account)
  end

  def self.do_sync_transactions(connection, account)
    now = Date.today
    thirty_days_ago = (now - 30)
    response = plaid.transactions.get(connection.access_token, thirty_days_ago, now, account_ids: [account.account_id])

    transactions = response.transactions
    transactions_handled = transactions.length
    handle_transaction_page(account, transactions)

    while transactions_handled < response['total_transactions']
      response = plaid.transactions.get(connection.access_token,
                                          thirty_days_ago, 
                                          now,
                                          offset: transactions_handled,
                                          account_ids: [account.account_id])
      
      transactions = response.transactions
      transactions_handled += transactions.length
      handle_transaction_page(account, transactions)
    end

    account.last_synced_at = DateTime.now
    account.save
  rescue => err
    account.last_sync_error_at = DateTime.now
    account.last_sync_error = err
    account.save
  end

  def self.handle_transaction_page(account, transactions)
    transactions.each do |t|
      account.transactions.where(transaction_id: t.transaction_id)
       .first_or_create!(
         amount: t.amount,
         category: t.category&.join(', '),
         category_id: t.category_id,
         date: t.date,
         iso_currency_code: t.iso_currency_code,
         name: t.name,
         pending: t.pending,
         transaction_type: t.transaction_type
       )
     end
  end

  protected

  def account_params
    params.require(:account).permit(
      :hidden_from_snapshot, 
      :archived,
      :exclude_from_available, 
      :payment_link)
  end
end
