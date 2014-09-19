require 'rspec'

describe 'Scheduler' do
  # set constants used by spherical factories
  #POINT(-72.9109308480767 41.3187459427293) | POINT(-72.9038633595772 41.3121938789795) | a
  HOME1_LONGITUDE = -72.9109308480767
  HOME1_LATITUTE = 41.3187459427293
  WORK1_LONGITUDE = -72.9038633595772
  WORK1_LATITUTE = 41.3121938789795

  #POINT(-72.91102501844 41.3189297086803)   | POINT(-72.9081076060728 41.3133458958975) | a
  HOME2_LONGITUDE = -72.91102501844
  HOME2_LATITUDE = 41.3189297086803
  WORK2_LONGITUDE = -72.9081076060728
  WORK2_LATITUDE = 41.3133458958975

  HOME3_LONGITUDE = -72.917
  HOME3_LATITUDE = 41.323
  WORK3_LONGITUDE = -72.9082
  WORK3_LATITUDE = 41.3134

  HOME4_LONGITUDE = -72.917
  HOME4_LATITUDE = 41.322
  WORK4_LONGITUDE = -72.9082
  WORK4_LATITUDE = 41.3132

  let(:home1) {RGeo::Geographic.spherical_factory( :srid => 4326 ).point(HOME1_LONGITUDE, HOME1_LATITUTE)}
  let(:work1) {RGeo::Geographic.spherical_factory( :srid => 4326 ).point(WORK1_LONGITUDE, WORK1_LATITUTE)}
  let(:home2) {RGeo::Geographic.spherical_factory( :srid => 4326 ).point(HOME2_LONGITUDE, HOME2_LATITUDE)}
  let(:work2) {RGeo::Geographic.spherical_factory( :srid => 4326 ).point(WORK2_LONGITUDE, WORK2_LATITUDE)}

  let(:home3) {RGeo::Geographic.spherical_factory( :srid => 4326 ).point(HOME3_LONGITUDE, HOME3_LATITUDE)}
  let(:work3) {RGeo::Geographic.spherical_factory( :srid => 4326 ).point(WORK3_LONGITUDE, WORK3_LATITUDE)}

  let(:home4) {RGeo::Geographic.spherical_factory( :srid => 4326 ).point(HOME4_LONGITUDE, HOME4_LATITUDE)}
  let(:work4) {RGeo::Geographic.spherical_factory( :srid => 4326 ).point(WORK4_LONGITUDE, WORK4_LATITUDE)}

  let(:home_pickup) {DateTime.now.in_time_zone("Pacific Time (US & Canada)").change(hour: 7, min: 0, sec: 0) + 1.days}
  let(:work_pickup) {DateTime.now.in_time_zone("Pacific Time (US & Canada)").change(hour: 5, min: 0, sec: 0) + 1.days}

  let(:rider1) {FactoryGirl.create(:generated_rider)}
  let(:rider2) {FactoryGirl.create(:generated_rider)}
  let(:rider3) {FactoryGirl.create(:generated_rider)}
  let(:driver1) {FactoryGirl.create(:generated_driver)}


  before(:each) do
    Ride.delete_all
    Trip.delete_all
    Fare.delete_all
  end

  context 'Commuter Schedule' do
    it 'should schedule forward commuter rides' do

      aside1 = TripController.request_commute_leg(home1, "Home1", work1, "Work1", home_pickup, true, driver1.as_rider, 0 )
      aside2 = TripController.request_commute_leg(home2, "Home2", work2, "Work2", home_pickup, false, rider1, 0 )

      Scheduler.build_forward_fares

      aside1.state = 'scheduled'
      aside2.state = 'pending_return'
      expect(aside1.trip.state).to eq('requested')
      expect(aside2.trip.state).to eq('requested')

      expect(aside1.fare).to eq(aside2.fare)

    end

    it 'should schedule commuter rides for one driver and one rider' do
      aside1 = TripController.request_commute_leg(home1, "Home1", work1, "Work1", home_pickup, true, driver1.as_rider, 0 )
      bside1 = TripController.request_commute_leg(work1, "Work1", home1, "Home1", work_pickup, true, driver1.as_rider, aside1.trip_id)

      aside2 = TripController.request_commute_leg(home2, "Home2", work2, "Work2", home_pickup, false, rider1, 0 )
      bside2 = TripController.request_commute_leg(work2, "Work2", home2, "Home2", work_pickup, false, rider1, aside2.trip_id)

      Scheduler.build_forward_fares
      Scheduler.build_return_fares
      Scheduler.calculate_costs

      expect(aside1.trip.state).to eq('fulfilled')
      expect(bside1.trip.state).to eq('fulfilled')
      expect(aside2.trip.state).to eq('fulfilled')
      expect(bside2.trip.state).to eq('fulfilled')

      expect(aside1.fare).to eq(aside2.fare)
      expect(bside1.fare).to eq(bside2.fare)
    end

    it 'should schedule commuter forward rides for one driver and two riders with same times' do

      aside1 = TripController.request_commute_leg(home1, "Home1", work1, "Work1", home_pickup, true, driver1.as_rider, 0 )
      aside2 = TripController.request_commute_leg(home2, "Home2", work2, "Work2", home_pickup, false, rider1, 0 )
      aside3 = TripController.request_commute_leg(home2, "Home2", work2, "Work2", home_pickup, false, rider2, 0 )

      Scheduler.build_forward_fares

      expect(aside1.trip.state).to eq('requested')
      expect(aside2.trip.state).to eq('requested')
      expect(aside3.trip.state).to eq('requested')

      expect(aside1.fare).to eq(aside2.fare)
      expect(aside1.fare).to eq(aside3.fare)
    end

    it 'should schedule commuter rides for one driver and two riders with same times and same work' do
      aside1 = TripController.request_commute_leg(home1, "Home1", work1, "Work1", home_pickup, true, driver1.as_rider, 0 )
      bside1 = TripController.request_commute_leg(work1, "Work1", home1, "Home1", work_pickup, true, driver1.as_rider, aside1.trip_id)

      aside2 = TripController.request_commute_leg(home2, "Home2", work2, "Work2", home_pickup, true, rider1, 0 )
      bside2 = TripController.request_commute_leg(work2, "Work2", home2, "Home2", work_pickup, true, rider1, aside2.trip_id)

      aside3 = TripController.request_commute_leg(home3, "Home3", work2, "Work3", home_pickup, true, rider2, 0 )
      bside3 = TripController.request_commute_leg(work2, "Work3", home3, "Home3", work_pickup, true, rider2, aside3.trip_id)

      Scheduler.build_forward_fares
      Scheduler.build_return_fares
      Scheduler.calculate_costs

      expect(aside1.trip.state).to eq('fulfilled')
      expect(bside1.trip.state).to eq('fulfilled')
      expect(aside2.trip.state).to eq('fulfilled')
      expect(bside2.trip.state).to eq('fulfilled')
      expect(aside3.trip.state).to eq('fulfilled')
      expect(bside3.trip.state).to eq('fulfilled')

      expect(aside1.fare).to eq(aside2.fare)
      expect(aside1.fare).to eq(aside3.fare)

      expect(bside1.fare).to eq(bside2.fare)
      expect(bside1.fare).to eq(bside3.fare)
    end

    it 'should schedule commuter rides for one driver and two riders with same times and different work' do

      aside1 = TripController.request_commute_leg(home1, "Home1", work1, "Work1", home_pickup, true, driver1.as_rider, 0 )
      bside1 = TripController.request_commute_leg(work1, "Work1", home1, "Home1", work_pickup, true, driver1.as_rider, aside1.trip_id)

      aside2 = TripController.request_commute_leg(home2, "Home2", work2, "Work2", home_pickup, true, rider1, 0 )
      bside2 = TripController.request_commute_leg(work2, "Work2", home2, "Home2", work_pickup, true, rider1, aside2.trip_id)

      aside3 = TripController.request_commute_leg(home3, "Home3", work3, "Work3", home_pickup, true, rider2, 0 )
      bside3 = TripController.request_commute_leg(work3, "Work3", home3, "Home3", work_pickup, true, rider2, aside3.trip_id)

      Scheduler.build_forward_fares
      Scheduler.build_return_fares
      Scheduler.calculate_costs

      expect(aside1.trip.state).to eq('fulfilled')
      expect(bside1.trip.state).to eq('fulfilled')
      expect(aside2.trip.state).to eq('fulfilled')
      expect(bside2.trip.state).to eq('fulfilled')
      expect(aside3.trip.state).to eq('fulfilled')
      expect(bside3.trip.state).to eq('fulfilled')

      expect(aside1.fare).to eq(aside2.fare)
      expect(aside1.fare).to eq(aside3.fare)

      expect(bside1.fare).to eq(bside2.fare)
      expect(bside1.fare).to eq(bside3.fare)
    end

    it 'should schedule commuter rides for one driver and three riders with same times and different work' do
      aside1 = TripController.request_commute_leg(home1, "Home1", work1, "Work1", home_pickup, true, driver1.as_rider, 0 )
      bside1 = TripController.request_commute_leg(work1, "Work1", home1, "Home1", work_pickup, true, driver1.as_rider, aside1.trip_id)

      aside2 = TripController.request_commute_leg(home2, "Home2", work2, "Work2", home_pickup, true, rider1, 0 )
      bside2 = TripController.request_commute_leg(work2, "Work2", home2, "Home2", work_pickup, true, rider1, aside2.trip_id)

      aside3 = TripController.request_commute_leg(home3, "Home3", work3, "Work3", home_pickup, true, rider2, 0 )
      bside3 = TripController.request_commute_leg(work3, "Work3", home3, "Home3", work_pickup, true, rider2, aside3.trip_id)

      aside4 = TripController.request_commute_leg(home4, "Home4", work4, "Work4", home_pickup, true, rider3, 0 )
      bside4 = TripController.request_commute_leg(work4, "Work4", home4, "Home4", work_pickup, true, rider3, aside4.trip_id)

      Scheduler.build_forward_fares
      Scheduler.build_return_fares
      Scheduler.calculate_costs

      expect(aside1.trip.state).to eq('fulfilled')
      expect(bside1.trip.state).to eq('fulfilled')
      expect(aside2.trip.state).to eq('fulfilled')
      expect(bside2.trip.state).to eq('fulfilled')
      expect(aside3.trip.state).to eq('fulfilled')
      expect(bside3.trip.state).to eq('fulfilled')
      expect(aside4.trip.state).to eq('fulfilled')
      expect(bside4.trip.state).to eq('fulfilled')

      expect(aside1.fare).to eq(aside2.fare)
      expect(aside1.fare).to eq(aside3.fare)
      expect(aside1.fare).to eq(aside4.fare)

      expect(bside1.fare).to eq(bside2.fare)
      expect(bside1.fare).to eq(bside3.fare)
      expect(bside1.fare).to eq(bside4.fare)
    end

    it 'should schedule commuter rides for one driver and one rider with time apart by 15 mins' do
      aside1 = TripController.request_commute_leg(home1, "Home1", work1, "Work1", home_pickup, true, driver1.as_rider, 0 )
      bside1 = TripController.request_commute_leg(work1, "Work1", home1, "Home1", work_pickup, true, driver1.as_rider, aside1.trip_id)

      aside2 = TripController.request_commute_leg(home2, "Home2", work2, "Work2", home_pickup + 15.minutes, false, rider1, 0 )
      bside2 = TripController.request_commute_leg(work2, "Work2", home2, "Home2", work_pickup, false, rider1, aside2.trip_id)

      Scheduler.build_forward_fares
      Scheduler.build_return_fares
      Scheduler.calculate_costs

      expect(aside1.trip.state).to eq('fulfilled')
      expect(bside1.trip.state).to eq('fulfilled')
      expect(aside2.trip.state).to eq('fulfilled')
      expect(bside2.trip.state).to eq('fulfilled')

      expect(aside1.fare).to eq(aside2.fare)
      expect(bside1.fare).to eq(bside2.fare)
    end

    it 'should schedule commuter rides for one driver and two riders with different times' do
      aside1 = TripController.request_commute_leg(home1, "Home1", work1, "Work1", home_pickup, true, driver1.as_rider, 0 )
      bside1 = TripController.request_commute_leg(work1, "Work1", home1, "Home1", work_pickup, true, driver1.as_rider, aside1.trip_id)

      aside2 = TripController.request_commute_leg(home2, "Home2", work2, "Work2", home_pickup + 15.minutes, true, rider1, 0 )
      bside2 = TripController.request_commute_leg(work2, "Work2", home2, "Home2", work_pickup, true, rider1, aside2.trip_id)

      aside3 = TripController.request_commute_leg(home3, "Home3", work3, "Work3", home_pickup + 15.minutes, true, rider2, 0 )
      bside3 = TripController.request_commute_leg(work3, "Work3", home3, "Home3", work_pickup, true, rider2, aside3.trip_id)

      Scheduler.build_forward_fares
      Scheduler.build_return_fares
      Scheduler.calculate_costs

      expect(aside1.trip.state).to eq('fulfilled')
      expect(bside1.trip.state).to eq('fulfilled')
      expect(aside2.trip.state).to eq('fulfilled')
      expect(bside2.trip.state).to eq('fulfilled')
      expect(aside3.trip.state).to eq('fulfilled')
      expect(bside3.trip.state).to eq('fulfilled')

      expect(aside1.fare).to eq(aside2.fare)
      expect(aside1.fare).to eq(aside3.fare)

      expect(bside1.fare).to eq(bside2.fare)
      expect(bside1.fare).to eq(bside3.fare)
    end

    it 'should schedule commuter rides for one driver and two riders with different times' do
      aside1 = TripController.request_commute_leg(home1, "Home1", work1, "Work1", home_pickup + 15, true, driver1.as_rider, 0 )
      bside1 = TripController.request_commute_leg(work1, "Work1", home1, "Home1", work_pickup, true, driver1.as_rider, aside1.trip_id)

      aside2 = TripController.request_commute_leg(home2, "Home2", work2, "Work2", home_pickup, true, rider1, 0 )
      bside2 = TripController.request_commute_leg(work2, "Work2", home2, "Home2", work_pickup, true, rider1, aside2.trip_id)

      aside3 = TripController.request_commute_leg(home3, "Home3", work3, "Work3", home_pickup + 15.minutes, true, rider2, 0 )
      bside3 = TripController.request_commute_leg(work3, "Work3", home3, "Home3", work_pickup, true, rider2, aside3.trip_id)

      Scheduler.build_forward_fares
      Scheduler.build_return_fares
      Scheduler.calculate_costs

      expect(aside1.trip.state).to eq('fulfilled')
      expect(bside1.trip.state).to eq('fulfilled')
      expect(aside2.trip.state).to eq('fulfilled')
      expect(bside2.trip.state).to eq('fulfilled')
      expect(aside3.trip.state).to eq('fulfilled')
      expect(bside3.trip.state).to eq('fulfilled')

      expect(aside1.fare).to eq(aside2.fare)
      expect(aside1.fare).to eq(aside3.fare)

      expect(bside1.fare).to eq(bside2.fare)
      expect(bside1.fare).to eq(bside3.fare)

    end
  end
end
