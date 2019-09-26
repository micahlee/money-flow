class ApplicationController < ActionController::Base
  protected

  def self.plaid
    Plaid::Client.new(env: ENV['PLAID_ENV'],
                      client_id: ENV['PLAID_CLIENT_ID'],
                      secret: ENV['PLAID_SECRET'],
                      public_key: ENV['PLAID_PUBLIC_KEY'])
  end

  def plaid
    ApplicationController.plaid
  end
end
