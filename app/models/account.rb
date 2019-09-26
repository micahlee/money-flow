class Account < ApplicationRecord
  belongs_to :connection
  has_many :funds

  has_many :transactions

  def uncleared_amount
    return nil if account_type == 'credit'

    @uncleared_amount ||= funds.map(&:pending_amount).sum
  end

  def available_amount
    return nil if account_type == 'credit'

    balance_current - uncleared_amount
  end

  def cash_amount
    return nil if account_type == 'credit'

    balance_current
  end

  def credit_amount
    return nil unless account_type == 'credit'

    balance_current
  end

end
