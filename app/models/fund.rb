class Fund < ApplicationRecord
  belongs_to :account
  has_many :transactions

  def pending_amount
    transactions.where(cleared: false)
                .sum(:amount)
  end
end
