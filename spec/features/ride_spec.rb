feature 'Rides' do
  ORIGIN = RGeo::Geographic.spherical_factory( :srid => 4326 ).point(-122, 47)
  ORIGIN_PLACE_NAME = 'origin name'
  DESTINATION = RGeo::Geographic.spherical_factory( :srid => 4326 ).point(-122, 47)
  DESTINATION_PLACE_NAME = 'destination name'

  let(:rider) {FactoryGirl.create(:rider)}
  let(:ride) {OnDemandRide.create!(ORIGIN, ORIGIN_PLACE_NAME, DESTINATION, DESTINATION_PLACE_NAME, rider)}
  let(:fare) {ride.fare}
  let(:scheduled_fare) {FactoryGirl.create(:scheduled_fare)}
  let(:scheduled_multirider_fare) {FactoryGirl.create(:scheduled_multirider_fare)}

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

  scenario 'driver declines fare' do
    2.times {FactoryGirl.create(:available_driver)}
    ride.request!
    drivers = Driver.available_drivers
    drivers.each {|driver| driver.offer_fare(fare)}
    denied_driver = drivers.first
    accepted_driver = drivers.last

    offer_to_decline = denied_driver.offers.where(fare_id: fare.id).first
    offer_to_decline.declined!
    offer_to_accept = accepted_driver.offers.where(fare_id: fare.id).first

    expect(offer_to_decline.state).to eq("declined")
    expect(offer_to_accept.state).to eq("offered")
  end

  scenario 'driver cancels scheduled fare' do
    scheduled_fare.driver_cancelled!
    expect(scheduled_fare.state).to eq("driver_cancelled")
    expect(scheduled_fare.finished).to_not be(nil)
  end

  scenario "rider cancels single rider fare" do
    scheduled_fare.rider_cancelled!(scheduled_fare.riders.first)
    expect(scheduled_fare.state).to eq("rider_cancelled")
    expect(scheduled_fare.finished).to_not be(nil)
  end

  scenario "rider cancels multi rider fare" do
    scheduled_multirider_fare.rider_cancelled!(scheduled_multirider_fare.riders.first)
    expect(scheduled_multirider_fare.state).to eq("scheduled")
    expect(scheduled_multirider_fare.finished).to be(nil)
  end

  scenario 'both riders cancel multi rider fare' do
    riders = []
    scheduled_multirider_fare.riders.each {|rider| riders.push(rider)}
    riders.each {|rider| scheduled_multirider_fare.rider_cancelled!(rider)}
    expect(scheduled_multirider_fare.state).to eq("rider_cancelled")
    expect(scheduled_multirider_fare.finished).to_not be nil
  end

  scenario 'rider gets picked up' do
    scheduled_fare.pickup!
    expect(scheduled_fare.state).to eq("started")
    expect(scheduled_fare.started).to_not be nil
  end

  scenario 'rider arrives at destination' do
    scheduled_fare.pickup!
    scheduled_fare.arrived!
    expect(scheduled_fare.state).to eq("completed")
    expect(scheduled_fare.finished).to_not be nil
  end
end
