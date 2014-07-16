class AddAttachmentCarPhotoToCars < ActiveRecord::Migration
  def self.up
    change_table :cars do |t|
      t.attachment :car_photo
    end
  end

  def self.down
    drop_attached_file :cars, :car_photo
  end
end
