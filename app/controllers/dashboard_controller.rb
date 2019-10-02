require 'csv'

class DashboardController < ApplicationController
  def index
    @transactions = Transaction.joins(:account)
                               .where(accounts: { hidden_from_snapshot: false})
                               .where(pending: false)
                               .where(cleared: false)
                               .where(fund_id: nil)
                               .order(date: :desc)
                               .all

    @accounts = Account.where(hidden_from_snapshot: false)
                       .order(balance_current: :desc)
                       .all

    @funds = Fund.order(:name).all

    @cash_total = @accounts.map(&:cash_amount).compact.sum
    @credit_total = @accounts.map(&:credit_amount).compact.sum
    @uncleared_total = @accounts.map(&:uncleared_amount).compact.sum
    @available_total = @accounts.reject { |a| a.exclude_from_available }.map(&:available_amount).compact.sum

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@transactions), filename: "transactions-#{Date.today}.csv" }
    end
  end

  private 

  def to_csv(transactions)
    CSV.generate do |csv|
      csv << [ "Date", "Account", "Name", "Amount" ]

      transactions.each do |t|
        csv << [ t.date, t.account.connection.name + ' - ' + t.account.name, t.name, t.amount ]
      end
    end
  end
end
