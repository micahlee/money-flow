class Connection < ApplicationRecord
  has_many :accounts

  def transactions(client)
    now = Date.today
    thirty_days_ago = (now - 30)
    client.transactions.get(access_token, thirty_days_ago, now)
  end
end
