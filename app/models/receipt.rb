class Receipt < ActiveRecord::Base
  belongs_to :trip
  belongs_to :user
  attr_accessible :type, :amount, :date, :trip_id, :user_id
  self.inheritance_column = :_type_disabled
end
