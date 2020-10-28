require 'csv'
require 'date'

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

    @flow_by_month = flow_by_month_chart
    @totals_by_month = totals_by_month_chart

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@transactions), filename: "transactions-#{Date.today}.csv" }
    end
  end


  def flow_by_month_chart
    results = flow_by_month.to_a

    months = results.map { |r| DateTime.parse(r['txn_month']).strftime('%b, %Y') }
    expenses = results.map { |r| r['expenses'] }
    income = results.map { |r| r['income'] }
    balances = results.map { |r| r['balance'] }

    return {
      labels: months,
      datasets: [
        {
          label: 'Expenses',
          data: expenses,
          borderColor: '#FF4136',
        },
        {
          label: 'Income',
          data: income,
          borderColor: '#2ECC40',
        },
        {
          label: 'Balance',
          data: balances,
          borderColor: '#0074D9',
        },
      ]
    }
  end

  def totals_by_month_chart
    results = totals_by_month.to_a

    months = results.map { |r| DateTime.parse(r['month']).strftime('%b, %Y') }
    credit = results.map { |r| r['credit - credit card'] }
    checking = results.map { |r| r['depository - checking'] }
    savings = results.map { |r| r['depository - savings'] }

    student_loan = results.map { |r| r['loan - student'] }
    loan = results.map { |r| r['loan - loan'] }

    debt = loan.zip(student_loan).map do |parts|
      (parts[0].to_f + parts[1].to_f).to_s
    end

    return {
      labels: months,
      datasets: [
        {
          label: 'Credit',
          data: credit,
          borderColor: '#FF4136',
        },
        {
          label: 'Checking',
          data: checking,
          borderColor: '#2ECC40',
        },
        {
          label: 'Savings',
          data: savings,
          borderColor: '#0074D9',
        },
        {
          label: 'Debt',
          data: debt,
          borderColor: '#000000',
        },
      ]
    }
  end

  private


  def flow_by_month
    query = <<-SQL
    SELECT 
          date_trunc('month', t.created_at) AS txn_month,
        SUM(case when t.amount >= 0 then amount end) * -1 as expenses,
        SUM(case when t.amount < 0 then amount end) * -1 as income,
        SUM(t.amount) * -1 as balance
    FROM 
        transactions t
        LEFT JOIN accounts a on a.id = t.account_id

    WHERE
        t.pending = false
        AND a.hidden_from_snapshot = false
        AND a.account_type not in ('investment', 'loan')
        And t.fund_id not in (18)
    GROUP BY
        txn_month
    ORDER BY
        txn_month;
    SQL

    ActiveRecord::Base.connection.select_all(query)
  end

  def totals_by_month
    query = <<-SQL
      WITH
      months as (
          SELECT DISTINCT
              date_trunc('month', t.created_at) as month
          FROM 
              transactions t
      ),

      monthly_data as (
          select
              m.month
              ,a.account_type
              ,CONCAT(a.account_type, ' - ', a.account_subtype) as type
              ,SUM(COALESCE(t.amount, 0) * -1) as total_amount
          FROM 
              months m
              CROSS JOIN accounts a
              LEFT JOIN transactions t on date_trunc('month', t.created_at) = m.month AND t.account_id = a.id
          WHERE
              t.pending = false OR t.pending is null
          group by
              m.month,
              a.account_type,
            a.account_subtype
      ),
      current_data as (
          SELECT
              CONCAT(account_type, ' - ', account_subtype) as type
              ,SUM(balance_current) as current_balance
          FROM
              accounts
          GROUP BY
              account_type
              ,account_subtype
      ),
      totals as (
          SELECT
              CONCAT(a.account_type, ' - ', a.account_subtype) as type
              ,SUM(COALESCE(t.amount, 0) * -1) as total_amount
          FROM  
              accounts a
              LEFT JOIN transactions t ON t.account_id = a.id
          WHERE
              t.pending = false or t.pending is null
          group by
              a.account_type,
              a.account_subtype
      ),
      monthly_accumulating as (
          select
              month
              ,account_type
              ,type
              ,total_amount as total
              ,sum(total_amount) over (PARTITION BY type order by month asc rows between unbounded preceding and current row) as accumulating_total
          from
              monthly_data
          order by month asc, type
      ),

      snapshots as (
      select
          monthly.month
          ,monthly.type
          ,monthly.total
          ,monthly.accumulating_total
          ,totals.total_amount
          ,(totals.total_amount - monthly.accumulating_total) as inverse_accumulating_total
          ,current.current_balance
          ,CASE
              WHEN monthly.account_type = 'credit' OR monthly.account_type = 'loan'
                  THEN (current.current_balance + (totals.total_amount - monthly.accumulating_total))
              ELSE
                  (current.current_balance - (totals.total_amount - monthly.accumulating_total))
          END as snapshot_balance
      from
          monthly_accumulating monthly
          LEFT JOIN current_data current on current.type = monthly.type
          LEFT JOIN totals on totals.type = monthly.type
      )

      SELECT
          month
          ,SUM(CASE WHEN type='investment - retirement' THEN snapshot_balance END) AS "investment - retirement"
          ,SUM(CASE WHEN type='investment - brokerage' THEN snapshot_balance END) AS "investment - brokerage"
          ,SUM(CASE WHEN type='investment - 401k' THEN snapshot_balance END) AS "investment - 401k"
          ,SUM(CASE WHEN type='investment - hsa' THEN snapshot_balance END) AS "investment - hsa"
          ,SUM(CASE WHEN type='loan - loan' THEN snapshot_balance END) AS "loan - loan"
          ,SUM(CASE WHEN type='loan - student' THEN snapshot_balance END) AS "loan - student"
          ,SUM(CASE WHEN type='depository - savings' THEN snapshot_balance END) AS "depository - savings"
          ,SUM(CASE WHEN type='depository - checking' THEN snapshot_balance END) AS "depository - checking"
          ,SUM(CASE WHEN type='credit - credit card' THEN snapshot_balance END) AS "credit - credit card"

      FROM
          snapshots
      GROUP BY
          month
      ORDER BY
          month
    SQL

    ActiveRecord::Base.connection.select_all(query)
  end

  def to_csv(transactions)
    CSV.generate do |csv|
      csv << [ "Date", "Account", "Name", "Amount" ]

      transactions.each do |t|
        csv << [ t.date, t.account.connection.name + ' - ' + t.account.name, t.name, t.amount ]
      end
    end
  end
end
