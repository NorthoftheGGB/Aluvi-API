feature 'Rides' do
  ORIGIN = RGeo::Geographic.spherical_factory( :srid => 4326 ).point(-122, 47)
  ORIGIN_PLACE_NAME = 'origin name'
  DESTINATION = RGeo::Geographic.spherical_factory( :srid => 4326 ).point(-122, 47)
  DESTINATION_PLACE_NAME = 'destination name'

  let(:rider) {FactoryGirl.create(:rider)}
  let(:ride) {OnDemandRide.create!(ORIGIN, ORIGIN_PLACE_NAME, DESTINATION, DESTINATION_PLACE_NAME, rider)}
  let(:fare) {ride.fare}

  scenario 'request on demand ride' do
    ride.request!
    expect(fare).to_not be(nil)
    expect(fare.meeting_point).to_not be(nil)
    expect(fare.drop_off_point).to_not be(nil)
  end

  scenario 'driver accepts fare' do
    2.times {FactoryGirl.create(:available_driver)}
    ride.request!
    driver = Driver.available_drivers.first
    driver.offer_fare(fare)

    offer = driver.offers.where(fare_id: fare.id).first
    expect(offer).to_not be(nil)

    offer.accepted!
    fare.accepted!(driver)
    expect(fare.state).to eq("scheduled")
    expect(offer.state).to eq("accepted")
  end


end
