require 'mapquest'
module RidesHelper

	def self.reverse_geocode location 
		mapquest = MapQuest.new "Fmjtd|luur2guan0,b5=o5-9azxgz"	
		coordinates = [ location.latitude, location.longitude ]
		data = mapquest.geocoding.reverse( coordinates )
		street = data.response[:results][0][:locations][0][:street]
		if street == ""
			street = data.response[:results][0][:locations][0][:adminArea5] 
		end
		street

	end


end
