class Connection < ApplicationRecord
  has_many :accounts
  belongs_to :family

  def transactions(client)
    now = Date.today
    thirty_days_ago = (now - 30)
    client.transactions.get(access_token, thirty_days_ago, now)
  end

  def connection_ok?
    return true if archived?
    
    accounts.all? { |account| account.sync_ok? || account.archived? }
  end
end
