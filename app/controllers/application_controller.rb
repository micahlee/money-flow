class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"

    if exception.action == :read
      raise ActiveRecord::RecordNotFound
    else
      redirect_to root_url, alert: 'Access denied!'
    end
  end

  def load_and_authorize_family
    @family = Family.find(params[:family_id])
    authorize! :read, @family
  end

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
