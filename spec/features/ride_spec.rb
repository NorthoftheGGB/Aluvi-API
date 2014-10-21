feature 'Rides' do
  ORIGIN = RGeo::Geographic.spherical_factory( :srid => 4326 ).point(-122, 47)
  ORIGIN_PLACE_NAME = 'origin name'
  DESTINATION = RGeo::Geographic.spherical_factory( :srid => 4326 ).point(-122, 47)
  DESTINATION_PLACE_NAME = 'destination name'

  let(:rider) {FactoryGirl.create(:rider)}
  let(:ride) {OnDemandRide.create!(ORIGIN, ORIGIN_PLACE_NAME, DESTINATION, DESTINATION_PLACE_NAME, rider)}

  scenario 'request on demand ride' do
    ride.request!
    fare = ride.fare
    expect(fare).to_not be(nil)
    expect(fare.meeting_point).to_not be(nil)
    expect(fare.drop_off_point).to_not be(nil)
  end
end
