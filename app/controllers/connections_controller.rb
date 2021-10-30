require 'plaid'

class ConnectionsController < ApplicationController
  before_action :load_and_authorize_family

  def index
    @tables = [
      {
        title: 'Active Connections',
        connections: @family.connections.where(archived: false)
      },
      {
        title: 'Archived Connections',
        connections: @family.connections.where(archived: true)
      },
    ]
  end
  
  def show
    @connection = Connection.find(params[:id])
    authorize! :read, @connection
    # @transactions = @connection.transactions(plaid)

    @tables = [
      {
        title: 'Active Accounts',
        accounts: @connection.accounts.where(archived: false)
      },
      {
        title: 'Archived Accounts',
        accounts: @connection.accounts.where(archived: true)
      },
    ]
  end

  def edit
    @connection = Connection.find(params[:id])
    authorize! :update, @connection

    @public_token = plaid.item.public_token.create(@connection.access_token).public_token
  end

  def update
    @connection = Connection.find(params[:id])
    authorize! :update, @connection
 
    if @connection.update(connection_params)
      redirect_to connection_path(@family, @connection)
    else
      render 'edit'
    end
  end

  def new
    authorize! :update, @family
  end

  def create
    authorize! :update, @family
    @connection = Connection.new(connection_params)
 
    @connection.save
    redirect_to @connection
  end

  def destroy
    @connection = Connection.find(params[:id])
    authorize! :delete, @connection

    @connection.destroy
  
    redirect_to connections_path
  end

  def access_token
    exchange_token_response =
      plaid.item.public_token.exchange(params['public_token'])
    render json: exchange_token_response
  end

  def sync_accounts  
    @connection = Connection.find(params[:id])
    authorize! :sync, @connection

    ConnectionsController.do_sync_accounts(@connection)  
  end

  def sync_all
    authorize! :sync, @family

    Connection.all.each do |conn|
      next if conn.archived?

      ConnectionsController.do_sync_accounts(conn)

      conn.accounts.each do |acct|
        next if acct.archived?

        AccountsController.do_sync_transactions(conn, acct)
      end
    end

    redirect_to dashboard_path
  end

  def self.do_sync_accounts(connection)
    existing_account_ids = connection.accounts.pluck(&:id)
    response = plaid.accounts.get(connection.access_token)
    response.accounts.each do |account|
      account_model = connection.accounts.where(account_id: account.account_id)
        .first_or_create!(
          account_type: account.type,
          account_subtype: account.subtype,
          mask: account.mask
        )

      account_model.update!(
        balance_current: account.balances.current,
          balance_available: account.balances.available,
          iso_currency_code: account.balances.iso_currency_code,
          name: account.name,
          official_name: account.official_name,
      )

      existing_account_ids.delete(account_model.id)
    end
  rescue => err
    p connection.name
    p err
    p err.backtrace
  end

  private

  def connection_params
    params.require(:connection).permit(
      :name, 
      :access_token, 
      :archived,
      :item_id)
  end
end
