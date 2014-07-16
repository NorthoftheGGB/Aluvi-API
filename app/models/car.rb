class Car < ActiveRecord::Base
	belongs_to :driver, :class_name => User, inverse_of: :cars
	has_many :rides, inverse_of: :car
	attr_accessible :license_plate, :make, :model, :state, :year, :car_photo
	has_attached_file :car_photo,  :styles => { :thumb => "160x66#" }, :default_url => "/images/missing.png", :storage => :s3 
	validates_attachment_content_type :car_photo, :content_type => /\Aimage\/.*\Z/ 

	def summary
		self.year + ' ' + self.make + ' '+  self.model
	end

end
