class HomeController < ApplicationController
  # GET /families or /families.json
  def index
    @families = current_user.families
  end
end
