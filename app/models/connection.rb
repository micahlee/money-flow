class Connection < ApplicationRecord
  has_many :accounts

  def transactions(client)
    now = Date.today
    thirty_days_ago = (now - 30)
    client.transactions.get(access_token, thirty_days_ago, now)
  end

  def connection_ok?
    accounts.all? { |account| account.sync_ok? }
  end
end
