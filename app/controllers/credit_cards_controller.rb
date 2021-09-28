class CreditCardsController < ApplicationController
  before_action :load_and_authorize_family

  def index
    @credit_cards = Account
                       .joins(:connection)
                       .where(connections: { family_id: @family.id })
                       .where(account_type: 'credit')
                       .order(balance_current: :desc)
                       .all
  end
end
