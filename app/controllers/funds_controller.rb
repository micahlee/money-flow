require 'color-generator'

class FundsController < ApplicationController
  def index
    @funds = Fund.order(:name)
                 .reject { |fund| ['Transfers', 'Income'].include? fund.name }

    @funds_by_month = funds_by_month
  end

  def new 
  end

  def show
    @fund = Fund.find(params['id'])

    @transactions = @fund.transactions.joins(:account)
                        .where(pending: false)
                        .where(cleared: false)
                        .order(date: :desc)
                        .all

                        dt = DateTime.now
    bom = dt.beginning_of_month
    eom = dt.end_of_month

    @all_transactions = @fund.transactions.joins(:account)
                             .order(date: :desc)
                             .all

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@transactions), filename: "#{@fund.name}-#{Date.today}.csv" }
    end                        
  end

  def clear_all_pending
    @fund = Fund.find(params['id'])
    @uncleared_transactions = @fund.transactions.joins(:account)
                              .where(pending: false)
                              .where(cleared: false)
                              .order(date: :desc)
                              .all
    
    @uncleared_transactions.each do |t|
      t.update!(cleared: true)
    end

    head :no_content
  end

  def create
    @fund = Fund.new(fund_params)
 
    @fund.save
    redirect_to @fund
  end

  def edit
    @fund = Fund.find(params[:id])
  end

  def update
    @fund = Fund.find(params[:id])
 
    if @fund.update(fund_params)
      redirect_to @fund
    else
      render 'edit'
    end
  end

  private

  def fund_params
    params.require(:fund).permit(:name, :account_id, :auto_clear)
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

  def funds_by_month
    results = funds_by_month_data

    generator = ColorGenerator.new saturation: 0.3, lightness: 0.75
    months = results.map { |r| r['txn_month']}.uniq
    series = results.map { |r| r['name'] }.uniq

    datasets = series.map do |name|
      data = months.map do |month| 
        result = results.find { |row| row['txn_month'] == month && row['name'] == name }
        result.nil? ? 0 : result['total']
      end

      color = generator.create_hex

      {
        label: name,
        borderColor: "##{color}",
        data: data
      }
    end

    return {
      labels: months.map {|m| DateTime.parse(m).strftime('%b, %Y')},
      datasets: datasets
    }
  end

  def funds_by_month_data
    query = <<-SQL
    SELECT 
        date_trunc('month', TO_DATE(t.date, 'YYYY-MM-DD')) AS txn_month,
        f.name, 
        SUM(t.amount) as total
    FROM 
        transactions t
        LEFT JOIN funds f on f.id = t.fund_id
        LEFT JOIN accounts a on a.id = t.account_id

    WHERE
        t.pending = false
        AND a.account_type not in ('investment', 'loan')
        AND f.name not in ('Transfers', 'Income' )
        AND a.hidden_from_snapshot = false
        
    GROUP BY
        txn_month,
        f.name
    ORDER BY
        txn_month,
        total desc;
    SQL

    ActiveRecord::Base.connection.select_all(query)
  end
end
