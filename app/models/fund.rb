class Fund < ApplicationRecord
  belongs_to :account, optional: true
  has_many :transactions

  def pending_amount
    transactions.where(cleared: false)
                .where(pending: false)   
                .sum(:amount)
  end

  def average
    a = transactions.where(pending: false)
                    .where("date < ?", DateTime.now.beginning_of_month)
                    .group("EXTRACT(month from TO_DATE(date, 'YYYY-MM-DD'))")
                    .sum(:amount).values
    a.reduce(:+) / a.size.to_f
  end

  def expected_remaining
    average_n_months(3) - total_this_month
  end

  def average_n_months(n)
    a = transactions.where("date >= ?", n.months.ago)
                    .where("date < ?", DateTime.now.beginning_of_month)
                    .where(pending: false)  
                    .group("EXTRACT(month from TO_DATE(date, 'YYYY-MM-DD'))")
                    .sum(:amount)
                    .values
    
    return 0 if a.empty?

    a.reduce(0, :+) / n
  end

  def total_this_month
    dt = DateTime.now
    bom = dt.beginning_of_month
    eom = dt.end_of_month
    transactions.where("date >= ? and date <= ?", bom, eom)
                .where(pending: false)    
                .sum(:amount)
  end

  def total_last_month
    dt = 1.month.ago
    bom = dt.beginning_of_month
    eom = dt.end_of_month
    transactions.where("date >= ? and date <= ?", bom, eom)
                .where(pending: false)    
                .sum(:amount)
  end
end
