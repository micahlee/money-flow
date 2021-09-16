require 'color-generator'

class FundsController < ApplicationController
  before_action :load_and_authorize_family

  def index
    authorize! :read, @family

    @funds = @family.funds.order(:name)
                 .reject { |fund| ['Transfers', 'Income'].include? fund.name }

    @funds_by_month = funds_by_month
  end

  def show
    @fund = Fund.find(params['id'])
    authorize! :read, @fund

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
    authorize! :read, @fund

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

  def new 
    authorize! :update, @family
  end

  def create
    authorize! :update, @family

    @fund = Fund.new(fund_params)
 
    @fund.save
    redirect_to @fund
  end

  def edit
    @fund = Fund.find(params[:id])
    authorize! :update, @fund
  end

  def update
    @fund = Fund.find(params[:id])
    authorize! :update, @fund
 
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
    start_date = (DateTime.now - 12.months).beginning_of_month
    query = <<-SQL
    SELECT 
        date_trunc('month', TO_DATE(t.date, 'YYYY-MM-DD')) AS txn_month,
        f.name, 
        SUM(t.amount) as total
    FROM 
        transactions t
        LEFT JOIN funds f on f.id = t.fund_id
        LEFT JOIN accounts a on a.id = t.account_id
        LEFT JOIN connections c on c.id = a.connection_id

    WHERE
        t.pending = false
        AND a.account_type not in ('investment', 'loan')
        AND f.name not in ('Transfers', 'Income' )
        AND a.hidden_from_snapshot = false
        AND t.date >= '#{start_date}'
        AND f.family_id = #{@family.id}
        AND c.family_id = #{@family.id}
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
