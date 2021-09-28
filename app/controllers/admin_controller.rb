class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin

  def authorize_admin
    unless current_user.admin?
      raise ActionController::RoutingError, "Not found"
    end
  end
end
