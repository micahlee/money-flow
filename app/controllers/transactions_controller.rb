class TransactionsController < ApplicationController
  before_action :load_and_authorize_family

  def all
    authorize! :read, @family

    @page = params['page']&.to_i || 1
    @per_page = params['per_page']&.to_i || 100

    transactions_query = Transaction
      .joins(account: [ :connection ])
      .where(accounts: { hidden_from_snapshot: false})
      .where(accounts: { connections: { family_id: @family.id } })
      .where(pending: false)
      .order('date desc')

    @transaction_count = transactions_query.count()
    @page_count = (@transaction_count / @per_page).ceil

    @page = 1 if @page < 1
    @page = @page_count if @page > @page_count

    offset = (@page - 1) * @per_page

    @transactions = transactions_query
      .offset(offset)
      .limit(@per_page)
      .all

    @funds = @family.funds.order(:name).all
  end

  def review
    authorize! :read, @family

    @transactions = Transaction.joins(:fund, account: [ :connection ])
      .where(date: Time.now.beginning_of_month..Time.now.end_of_month)
      .where(accounts: { connections: { family_id: @family.id } })
      .where.not(funds: { name: 'Transfers'})
      .where(pending: false)
      .order('date desc')
      .all

    @income = @transactions.select { |t| t.amount < 0 }
    @expenses = @transactions.select { |t| t.amount >= 0 }

  end

  def clear
    @transaction = Transaction.find(params[:id])
    authorize! :update, @transaction

    @transaction.update!(cleared: true)

    head :no_content
  end

  def assign
    raise "No fund given" unless params[:fund_id].present?

    @fund = Fund.find(params[:fund_id])
    authorize! :read, @fund
    
    @transaction = Transaction.find(params[:id])
    authorize! :update, @transaction

    @transaction.update(
      fund_id: params[:fund_id], 
      note: params[:note],
      cleared: @fund.auto_clear
    )

    head :no_content
  end

  def split_form
    @transaction = Transaction.find(params[:id])
    authorize! :update, @transaction

    @split = OpenStruct.new(transactions: [])
    @split.transactions << OpenStruct.new(amount: @transaction.amount)
  end

  def split
    @orig_transaction = Transaction.find(params[:id])
    authorize! :update, @transaction

    split = params[:split]

    split[:transactions].values.each do |t|
      Transaction.create!(
        account: @orig_transaction.account,
        split_from: @orig_transaction,
        amount: t[:amount].to_d,
        category: @orig_transaction.category,
        category_id: @orig_transaction.category_id,
        date: @orig_transaction.date,
        iso_currency_code: @orig_transaction.iso_currency_code,
        name: @orig_transaction.name,
        pending: @orig_transaction.pending,
        transaction_type: @orig_transaction.transaction_type
      )
    end

    @orig_transaction.update!(cleared: true)
  end
end
