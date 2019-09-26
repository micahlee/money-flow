class FundsController < ApplicationController
  def index
    @funds = Fund.all
  end

  def new 
  end

  def show
    @fund = Fund.find(params['id'])

    @transactions = @fund.transactions.joins(:account)
                        .where(accounts: { hidden_from_snapshot: false})
                        .where(pending: false)
                        .where(cleared: false)
                        .order(date: :desc)
                        .all

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@transactions), filename: "#{@fund.name}-#{Date.today}.csv" }
    end                        
  end

  def create
    @fund = Fund.new(fund_params)
 
    @fund.save
    redirect_to @fund
  end

  private

  def fund_params
    params.require(:fund).permit(:name, :account_id)
  end 

  def to_csv(transactions)
    CSV.generate do |csv|
      csv << [ "Date", "Account", "Name", "Amount" ]

      transactions.each do |t|
        csv << [ t.date, t.account.connection.name + ' - ' + t.account.name, t.name, t.amount ]
      end

      csv << ["", "", "TOTAL", transactions.collect(&:amount).sum]
    end
  end
end
