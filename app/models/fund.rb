class Fund < ApplicationRecord
  belongs_to :account, optional: true
  has_many :transactions

  def pending_amount
    transactions.where(cleared: false)
                .where(pending: false)   
                .sum(:amount)
  end

  def average
    a = transactions.group("EXTRACT(month from created_at)").sum(:amount).values
    a.reduce(:+) / a.size.to_f
  end

  def total_this_month
    dt = DateTime.now
    bom = dt.beginning_of_month
    eom = dt.end_of_month
    transactions.where("created_at >= ? and created_at <= ?", bom, eom)
                .sum(:amount)
  end
end
