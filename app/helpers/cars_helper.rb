module CarsHelper
	def self.render_map_json car
		Jbuilder.encode do |json|
			json.id = car.id
			unless(car.driver.nil?)
				json.driver_name = car.driver.first_name + ' ' + car.driver.last_name
			end
			json.coordinates do
				json.longitude = car.location.longitude
				json.latitude = car.location.latitude
			end
		end
	end
end
