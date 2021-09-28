class HomeController < ApplicationController
  # GET /families or /families.json
  def index
    if current_user.families.count == 1
      redirect_to dashboard_path(current_user.families.first)
    else
      @families = current_user.families
    end
  end
end
