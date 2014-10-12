class Car < ActiveRecord::Base
	belongs_to :driver, inverse_of: :cars
	has_many :fares, inverse_of: :car
	attr_accessible :license_plate, :make, :model, :state, :year, :car_photo, :color
	has_attached_file :car_photo,  :styles => { :thumb => "160x66#" }, :default_url => "/images/missing.png", :storage => :s3
	validates_attachment_content_type :car_photo, :content_type => /\Aimage\/.*\Z/

	def summary
    summary = ''
    unless self.year.nil?
      summary += self.year + ' '
    end
    unless self.make.nil?
      summary += self.make + ' '
    end
    unless self.model.nil?
		  summary += self.model
    end
    summary
	end

end
