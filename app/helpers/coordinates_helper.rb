module CoordinatesHelper

	def self.render_json location
		Jbuilder.encode do |json|
			json.longitude = location.longitude
			json.latitude = location.latitude
		end
	end

end
