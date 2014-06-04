class PanelController < ApplicationController
  # GET /rides
  # GET /rides.json
  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end
end
