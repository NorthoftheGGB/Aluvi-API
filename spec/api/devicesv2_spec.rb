require 'rails_helper'

describe DevicesAPIV2 do

	include AuthHelper

	describe "PUT /api/v2/devices/disassociate_users" do
		it "returns success" do
			device = FactoryGirl.create(:device)
			rider = device.user
			put "/api/v2/devices/disassociate_user/"+device.uuid, {}, {'HTTP_AUTHORIZATION' => encode_credentials(rider.token)}
			Rails.logger.info response.status.to_s + ':' + response.body
			expect(response.status).to eq(200)
      device = Device.find(device.id)
      expect(device.user_id).to be(0)
    end
	end
end
