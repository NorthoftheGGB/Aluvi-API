class Snapshot < ActiveRecord::Base
	attr_accessible :before_fileid, :before_created, :after_fileid, :after_created, :id
end
