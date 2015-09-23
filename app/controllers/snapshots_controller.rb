class SnapshotsController < ApplicationController
	def index
		@snapshots = Snapshot.all
		respond_to do |format|
			format.html # index.html.erb
		end
	end
	def show
		@snapshot = nil
		if Snapshot.exists?(params[:id])
			@snapshot = Snapshot.find(params[:id])
		end
		respond_to do |format|		 
				format.json { render json: @snapshot }
		end
	end
	# GET /snapshots/latest.json
	def latest
		@snapshot = Snapshot.last
		respond_to do |format|
			format.json { render json: @snapshot }
		end
	end
end
