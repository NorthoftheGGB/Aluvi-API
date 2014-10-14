module ApiExceptions

	class WrongUserForEntityException < StandardError
		def self.message
			"Wrong user for entity"
		end
	end

	class RideNotAssignedToThisDriverException < StandardError
		def self.message
			"Ride not assigned to this driver"
		end
	end

	class RideNotAssignedToThisRiderException < StandardError
		def self.message
			"Ride not assigned to this rider"
		end
	end

	class UserNotFoundException < StandardError
		def self.message
			"That email is not currently registered"
		end
	end

	class BadPasswordException < StandardError
		def self.message
			"Password does not match this user"
		end
	end
end
