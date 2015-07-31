require 'rails_helper'

describe GeoAPI do

  include AuthHelper

  before { GeoAPI.before { env["api.tilt.root"] = "app/views/api" } }

  describe "PUT /api/geo/driver" do
    it "updates driver location" do
      @driver = FactoryGirl.create(:approved_driver)
      put "/api/geo/driver", {:latitude => 71.2, :longitude => -122.3}, {'HTTP_AUTHORIZATION' => encode_credentials(@driver.token)}
      expect(response.status).to eq(200)
    end
  end

  describe "GET /api/geo/driver/:id" do
    it "gets driver location" do
      @driver = FactoryGirl.create(:approved_driver)
      get "/api/geo/driver/"+@driver.id.to_s, {},  {'HTTP_AUTHORIZATION' => encode_credentials(@driver.token)}
      expect(response.status).to eq(200)
    end
  end

  describe "PUT /api/geo/rider" do
    it "updates rider location" do
      @rider = FactoryGirl.create(:rider)
      put "/api/geo/rider", {:latitude => 71.2, :longitude => -122.3}, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      expect(response.status).to eq(200)
    end
  end

  describe "GET /api/geo/rider/:id" do
    it "gets rider location" do
      @rider = FactoryGirl.create(:rider)
      get "/api/geo/rider/"+@rider.id.to_s, {}, {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      expect(response.status).to eq(200)
    end
  end

  describe "GET /api/geo/drivers" do
    it "gets all driver locations" do
      @rider = FactoryGirl.create(:rider)
      get "/api/geo/drivers", {'HTTP_AUTHORIZATION' => encode_credentials(@rider.token)}
      expect(response.status).to eq(200)
    end
  end

end
