class TransactionsController < ApplicationController

  def all
    @transactions = Transaction.joins(:account)
                               .where(accounts: { hidden_from_snapshot: false})
                               .where(pending: false)
                               .order('created_at desc')
                               .limit(100)
                               .all

    @funds = Fund.order(:name).all
  end

  def review
    @transactions = Transaction.joins(:fund)
      .where(created_at: Time.now.beginning_of_month..Time.now.end_of_month)
      .where.not(funds: { name: 'Transfers'})
      .where(pending: false)
      .order('created_at desc')
      .all

    @income = @transactions.select { |t| t.amount < 0 }
    @expenses = @transactions.select { |t| t.amount >= 0 }

  end

  def clear
    @transaction = Transaction.find(params[:id])
    @transaction.update!(cleared: true)
  end

  def assign
    raise "No fund given" unless params[:fund_id].present?
    raise "Invalid fund" unless (fund = Fund.find(params[:fund_id]))
    @transaction = Transaction.find(params[:id])

    @transaction.update(
      fund_id: params[:fund_id], 
      note: params[:note],
      cleared: fund.auto_clear
    )
  end

  def split_form
    @transaction = Transaction.find(params[:id])

    @split = OpenStruct.new(transactions: [])
    @split.transactions << OpenStruct.new(amount: @transaction.amount)
  end

  def split
    @orig_transaction = Transaction.find(params[:id])
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
