class Device < ActiveRecord::Base
	belongs_to :user, inverse_of: :devices
  attr_accessible :hardware, :os, :platform, :push_token, :uuid
end
