module ApiExceptions

	class WrongUserForEntityException < StandardError
		def message
			"Wrong user for entity"
		end
	end

	class RideNotAssignedToThisDriverException < StandardError
		def message
			"Ride not assigned to this driver"
		end
	end

	class RideNotAssignedToThisRiderException < StandardError
		def message
			"Ride not assigned to this rider"
		end
	end
end
