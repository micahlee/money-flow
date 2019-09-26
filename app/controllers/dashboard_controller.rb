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
