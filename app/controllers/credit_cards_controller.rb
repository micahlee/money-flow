class CreditCardsController < ApplicationController
  def index
    @credit_cards = Account
                       .where(account_type: 'credit')
                       .order(balance_current: :desc)
                       .all
  end
end
